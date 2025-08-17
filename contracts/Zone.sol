pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/proxy/Clones.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

import './interfaces/IZone.sol';
import './interfaces/ILRShare.sol';
import './storage/AssetMetadataStorage.sol';
import './registries/RoleRegistry.sol';

/// @title Zone
/// @author Kingsley Victor
/// @notice The contract representing a geographical zone
contract Zone is IZone, ERC721URIStorage, Pausable, ReentrancyGuard {
    // Share token implementation
    address public lrShareImplementation;

    // Market place address
    address public marketplace;

    uint256 public tokenId;
    address public factory;

    // Zone metadata
    string private _name;
    string private _symbol;
    uint24 private longitude;
    uint24 private latitude;

    // Asset metadata storage
    AssetMetadataStorage public assetMetadataStorage;

    // Map each token ID to the representing ERC20
    mapping(uint256 => address) public shareToken;

    // Number of trades per trade index
    uint24[] public trades;

    // Share token registry
    IShareTokenRegistry public shareTokenRegistry;

    constructor() ERC721('', '') {}

    function initialize(
        string memory name_,
        string memory symbol_,
        uint24 _latitude,
        uint24 _longitude,
        address _lrShareImplementation,
        IShareTokenRegistry _shareTokenRegistry
    ) external {
        if (factory != address(0)) revert AlreadyInitialized();
        factory = msg.sender;
        longitude = _longitude;
        latitude = _latitude;
        _name = name_;
        _symbol = symbol_;
        shareTokenRegistry = _shareTokenRegistry;

        assetMetadataStorage = new AssetMetadataStorage();
        lrShareImplementation = _lrShareImplementation;
        emit Initialize(name_, symbol_, _latitude, _longitude);
    }

    function metadata() external view override returns (uint24 lng, uint24 lat, uint256 id) {
        lng = longitude;
        lat = latitude;
        id = tokenId;
    }

    function mint(
        address to,
        uint256 appraisal,
        string memory metadataURI,
        address peggedAsset,
        uint24[4] memory factorWeights,
        uint8 assetType
    ) external whenNotPaused nonReentrant returns (uint256, address) {
        if (msg.sender != factory) revert OnlyFactory();
        ++tokenId;
        _safeMint(msg.sender, tokenId);
        assetMetadataStorage.setTokenURI(tokenId, metadataURI); // Set asset metadata
        // Salt
        bytes32 salt = keccak256(abi.encodePacked(address(this), block.timestamp, tokenId));
        address lrShare = Clones.cloneDeterministic(lrShareImplementation, salt);
        ILRShare(lrShare).initialize(tokenId, peggedAsset, factorWeights, AssetType(assetType));
        ILRShare(lrShare).mint(to, appraisal);
        shareToken[tokenId] = lrShare;
        emit Mint(tokenId, lrShare, metadataURI);
        return (tokenId, lrShare);
    }

    function burn(uint256 _tokenId) external override whenNotPaused nonReentrant returns (address shareTokenAddress) {
        if (msg.sender != factory) revert OnlyFactory();
        shareTokenAddress = shareToken[_tokenId];
        require(shareTokenAddress != address(0), 'SHARE_TOKEN_NOT_FOUND');
        uint256 burnAmount = IERC20(shareTokenAddress).balanceOf(address(this));
        _burn(_tokenId);
        delete shareToken[_tokenId];
        assetMetadataStorage.setTokenURI(_tokenId, ''); // Clear metadata
        ILRShare(shareTokenAddress).burn(burnAmount); // Burn the share token
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        return assetMetadataStorage.tokenURI(_tokenId);
    }

    function switchPauseState() external {
        if (msg.sender != factory) revert OnlyFactory();
        if (paused()) _unpause();
        else _pause();
    }

    function tradesLength() public view override returns (uint256) {
        return trades.length;
    }

    function exists(uint256 _tokenId) external view override returns (bool _exists) {
        address tokenOwner = _ownerOf(_tokenId);
        _exists = tokenOwner != address(0);
    }

    function updateTrades(bool isNewTradeIndex) external override {
        require(shareTokenRegistry.zone(msg.sender) == address(this), 'INVALID_CALLER');
        if (isNewTradeIndex) trades.push(0);
        else trades[trades.length - 1] += 1;
    }

    function setMarketplace(address _marketplace) external override {
        if (msg.sender != factory) revert OnlyFactory();
        marketplace = _marketplace;
    }
}
