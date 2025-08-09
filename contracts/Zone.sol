pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./interfaces/IZone.sol";
import "./interfaces/ILRShare.sol";
import "./storage/AssetMetadataStorage.sol";
import "./registries/RoleRegistry.sol";

contract Zone is IZone, ERC721URIStorage {
    // Share token implementation
    address public lrShareImplementation;

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

    constructor() ERC721("", "") {}

    function initialize(
        string memory name_,
        string memory symbol_,
        uint24 _longitude,
        uint24 _latitude,
        RoleRegistry roleRegistry,
        address storageAdmin,
        address _lrShareImplementation
    ) external {
        if (factory != address(0)) revert AlreadyInitialized();
        factory = msg.sender;
        longitude = _longitude;
        latitude = _latitude;
        _name = name_;
        _symbol = symbol_;

        assetMetadataStorage = new AssetMetadataStorage(roleRegistry, storageAdmin);
        lrShareImplementation = _lrShareImplementation;
    }

    function metadata() external view override returns (uint24 lng, uint24 lat, uint256 id) {
        lng = longitude;
        lat = latitude;
        id = tokenId;
    }

    function mint(address to, uint256 appraisal, string memory metadataURI) external returns (uint256, address) {
        if (msg.sender != factory) revert OnlyFactory();
        ++tokenId;
        _safeMint(msg.sender, tokenId);
        assetMetadataStorage.setTokenURI(tokenId, metadataURI); // Set asset metadata
        // Salt
        bytes32 salt = keccak256(abi.encodePacked(address(this), block.timestamp, tokenId));
        address lrShare = Clones.cloneDeterministic(lrShareImplementation, salt);
        ILRShare(lrShare).initialize(tokenId);
        ILRShare(lrShare).mint(to, appraisal);
        shareToken[tokenId] = lrShare;
        return (tokenId, lrShare);
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        return assetMetadataStorage.tokenURI(_tokenId);
    }
}
