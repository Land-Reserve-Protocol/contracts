pragma solidity ^0.8.0;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {IERC721Metadata} from '@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol';
import './interfaces/ILRShare.sol';
import './interfaces/IZone.sol';
import './libs/Constants.sol' as Constants;
import {TradeMath} from './libs/TradeMath.sol';

contract LRShare is ERC20, ILRShare {
    address public zone;
    uint256 public assetId;
    address public peggedAsset;
    uint256 public lastObservationUpdateTime;

    string private _name;
    string private _symbol;

    Observation[] public observations;

    uint8 public peggedAssetDecimals;
    uint24[4] public factorWeights;
    uint24 public categoryMultiplierDelta;

    constructor() ERC20('', '') {}

    function initialize(
        uint256 _assetId,
        address _peggedAsset,
        uint24[4] memory _factorWeights,
        AssetType assetType
    ) external {
        require(zone == address(0), 'ALREADY_INITIALIZED');
        require(_peggedAsset != address(0), 'PEGGED_ASSET_ZERO_ADDRESS');
        require(_peggedAsset.code.length > 0, 'PEGGED_ASSET_NOT_CONTRACT');
        require(_factorWeights.length == 4, 'FACTOR_WEIGHTS_LENGTH_INVALID');
        require(
            _factorWeights[0] + _factorWeights[1] + _factorWeights[2] + _factorWeights[3] ==
                Constants.BASE_NON_NATIVE_UNIT,
            'FACTOR_WEIGHTS_INVALID'
        );
        zone = msg.sender;
        assetId = _assetId;
        peggedAsset = _peggedAsset;

        if (assetType == AssetType.Residential) categoryMultiplierDelta = Constants.RESIDENTIAL;
        else if (assetType == AssetType.Commercial) categoryMultiplierDelta = Constants.COMMERCIAL;
        else if (assetType == AssetType.Industrial) categoryMultiplierDelta = Constants.INDUSTRIAL;
        else if (assetType == AssetType.Agricultural) categoryMultiplierDelta = Constants.AGRICULTURAL;
        else revert('INVALID_ASSET_TYPE');

        _name = string(abi.encodePacked(IERC721Metadata(zone).name(), '-', _assetId));
        _symbol = string(abi.encodePacked(IERC721Metadata(zone).symbol(), '-', _assetId));

        // Pegged asset
        ERC20 asset = ERC20(peggedAsset);
        uint8 decimals_ = asset.decimals();
        peggedAssetDecimals = decimals_;
        // Normalized price
        uint256 _currentPrice = 1 * 10 ** decimals_;

        // Initial observation
        Observation memory initialObservation = Observation({
            trades: Constants.ZER0,
            currentPrice: _currentPrice,
            buyVolume: Constants.ZER0,
            sellVolume: Constants.ZER0,
            buyEpsilon: Constants.ZER0,
            sellEpsilon: Constants.ZER0,
            momentum: Constants.ZER0,
            sentiment: Constants.ZER0
        });
        observations.push(initialObservation);
    }

    function _findPrice(
        uint256 basePrice,
        uint24 tokenTradeVolumeFactor,
        uint24 areaTradeVolumeFactor,
        uint24 momentum,
        uint24 sentiment
    ) private view returns (uint256 price) {
        uint256 weighted = (factorWeights[0] * tokenTradeVolumeFactor) +
            (factorWeights[1] * areaTradeVolumeFactor) +
            (factorWeights[2] * momentum) +
            (factorWeights[3] * categoryMultiplierDelta);
        price =
            basePrice *
            (Constants.BASE_NON_NATIVE_UNIT + (Constants.SENTIMENT_SENSITIVITY_COEFFICIENT * weighted)) *
            (Constants.BASE_NON_NATIVE_UNIT + sentiment);
        price = price / (weighted > 0 ? Constants.BASE_NON_NATIVE_UNIT ** 4 : Constants.BASE_NON_NATIVE_UNIT ** 3); // Normalize the price
    }

    function updateMarketFactors(uint24 buyVolume, uint24 sellVolume, uint256 buyPrice, uint256 sellPrice) external {
        // Zone
        IZone iZone = IZone(zone);
        // TO DO: Add caller check to ensure that this can only be called by an order contract or a node
        // Area volume factors
        uint256 tradesLength = iZone.tradesLength();
        uint24 lastTrades = iZone.trades(tradesLength - 1);
        uint24 previousTrades = tradesLength > 1 ? iZone.trades(tradesLength - 2) : lastTrades;
        uint24 areaRawVolumeFactor = TradeMath.rawVolumeFactor(lastTrades, previousTrades);
        uint24 areaSmoothedVolumeFactor = TradeMath.smoothedVolumeFactor(areaRawVolumeFactor, previousTrades);

        // Get the last observation
        Observation storage lastObservation = observations[observations.length - 1];

        {
            lastObservation.trades += 1;
            lastObservation.buyVolume += buyVolume;
            lastObservation.sellVolume += sellVolume;
            lastObservation.buyEpsilon += buyPrice * buyVolume;
            lastObservation.sellEpsilon += sellPrice * sellVolume;
        }

        {
            // Get observation two indices back
            Observation memory previousObservation = observations.length > 1
                ? observations[observations.length - 2]
                : lastObservation;

            lastObservation.momentum = TradeMath.momentumFactor(
                lastObservation.trades,
                previousObservation.currentPrice,
                previousObservation.momentum,
                peggedAssetDecimals
            );

            // Find sentiments
            uint24 rawSentiment = TradeMath.rawSentiment(
                Constants.SENTIMENT_SENSITIVITY_COEFFICIENT,
                lastObservation.buyEpsilon,
                lastObservation.sellEpsilon,
                lastObservation.buyVolume,
                lastObservation.sellVolume
            );
            uint24 sentimentAlpha = TradeMath.sentimentSmoothingFactorAlpha(
                rawSentiment,
                0,
                Constants.BASE_NON_NATIVE_UNIT
            );
            // Normalize sentiment
            lastObservation.sentiment = TradeMath.smoothedSentiment(
                sentimentAlpha,
                rawSentiment,
                previousObservation.sentiment
            );
            // Token volume factors
            uint24 tokenRawVolumeFactor = TradeMath.rawVolumeFactor(lastObservation.trades, previousObservation.trades);
            uint24 tokenSmoothedVolumeFactor = TradeMath.smoothedVolumeFactor(
                tokenRawVolumeFactor,
                previousObservation.trades
            );

            // Update the current price
            lastObservation.currentPrice = _findPrice(
                previousObservation.currentPrice,
                tokenSmoothedVolumeFactor,
                areaSmoothedVolumeFactor,
                lastObservation.momentum,
                lastObservation.sentiment
            );
        }

        iZone.updateTrades(false); // Update zone trade count

        uint256 updateDiff = block.timestamp - lastObservationUpdateTime;
        // If the update interval has been reached, create a new observation
        if (updateDiff >= Constants.DEFAULT_UPDATE_INTERVAL) {
            Observation memory newObservation = Observation({
                trades: Constants.ZER0,
                currentPrice: lastObservation.currentPrice,
                buyVolume: Constants.ZER0,
                sellVolume: Constants.ZER0,
                buyEpsilon: Constants.ZER0,
                sellEpsilon: Constants.ZER0,
                momentum: Constants.ZER0,
                sentiment: Constants.ZER0
            });
            observations.push(newObservation);
            lastObservationUpdateTime = block.timestamp;
            iZone.updateTrades(true); // Update zone trade index
        }
    }

    function mint(address to, uint256 amount) external {
        require(totalSupply() == 0, 'ALREADY_MINTED');
        require(msg.sender == zone, 'ONLY_ZONE_CAN_MINT');
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        require(msg.sender == zone, 'ONLY_ZONE_CAN_BURN');
        require(amount == totalSupply(), 'BURN_AMOUNT_MISMATCH');
        _burn(msg.sender, amount);
    }

    function observationsLength() external view override returns (uint256) {
        return observations.length;
    }
}
