pragma solidity ^0.8.0;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {IERC721Metadata} from '@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol';
import './interfaces/ILRShare.sol';
import './libs/Constants.sol';

contract LRShare is ERC20, ILRShare {
    address public zone;
    uint256 public assetId;
    address public peggedAsset;

    string private _name;
    string private _symbol;

    Observation[] public observations;

    constructor() ERC20('', '') {}

    function initialize(uint256 _assetId) external {
        require(zone == address(0), 'ALREADY_INITIALIZED');
        zone = msg.sender;
        assetId = _assetId;

        _name = string(abi.encodePacked(IERC721Metadata(zone).name(), '-', _assetId));
        _symbol = string(abi.encodePacked(IERC721Metadata(zone).symbol(), '-', _assetId));

        // Pegged asset
        ERC20 asset = ERC20(peggedAsset);
        uint8 decimals_ = asset.decimals();
        // Normalized price
        uint256 _currentPrice = 1 * 10 ** decimals_;

        // Initial observation
        Observation memory initialObservation = Observation({
            trades: 0,
            currentPrice: _currentPrice,
            buyVolume: 0,
            sellVolume: 0,
            buyPrice: 0,
            sellPrice: 0,
            momentum: 0
        });
        observations.push(initialObservation);
    }

    function mint(address to, uint256 amount) external {
        require(totalSupply() == 0, 'ALREADY_MINTED');
        require(msg.sender == zone, 'ONLY_ZONE_CAN_MINT');
        _mint(to, amount);
    }
}
