pragma solidity ^0.8.0;

import '@openzeppelin/contracts/proxy/Clones.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol';

import './utils/Modifiers.sol';
import './registries/RoleRegistry.sol';
import './interfaces/IZone.sol';
import './interfaces/IShareTokenRegistry.sol';
import './interfaces/IZoneRegistry.sol';
import './interfaces/IActions.sol';

contract Actions is Modifiers, Pausable, ReentrancyGuard, ERC721Holder, IActions {
    address public immutable zoneImplementation;
    address public immutable lrShareImplementation;
    address public immutable shareTokenRegistry;
    address public immutable zoneRegistry;
    address public immutable marketplace;

    error UnknownZone();

    constructor(
        address _zoneImplementation,
        address _lrShareImplementation,
        RoleRegistry roleRegistry,
        address _shareTokenRegistry,
        address _zoneRegistry,
        address _marketplace
    ) Modifiers() ERC721Holder() {
        zoneImplementation = _zoneImplementation;
        lrShareImplementation = _lrShareImplementation;
        shareTokenRegistry = _shareTokenRegistry;
        zoneRegistry = _zoneRegistry;
        marketplace = _marketplace;
        _setRoleRegistry(roleRegistry);
    }

    function deployZone(
        string memory name,
        string memory symbol,
        uint24 lat,
        uint24 lng
    ) external onlyCouncilMember whenNotPaused nonReentrant returns (address zone) {
        bytes32 salt = keccak256(abi.encodePacked(name, symbol, lat, lng));
        zone = Clones.cloneDeterministic(zoneImplementation, salt);
        emit NewZone(zone, name, symbol, lat, lng);
        IZone(zone).initialize(name, symbol, lat, lng, lrShareImplementation, IShareTokenRegistry(shareTokenRegistry));
        IZone(zone).setMarketplace(marketplace);
        IZoneRegistry(zoneRegistry).registerZone(zone);
    }

    function mintWithinZone(
        address zone,
        address to,
        uint256 totalShares,
        string memory tokenURI,
        address peggedAsset,
        uint24[4] memory factorWeights,
        uint8 assetType
    ) external onlyCouncilMember whenNotPaused nonReentrant {
        if (!IZoneRegistry(zoneRegistry).isZone(zone)) revert UnknownZone();
        (, address shareToken) = IZone(zone).mint(to, totalShares, tokenURI, peggedAsset, factorWeights, assetType);
        IShareTokenRegistry(shareTokenRegistry).registerShareToken(shareToken);
        IShareTokenRegistry(shareTokenRegistry).switchTradeability(shareToken);
        IShareTokenRegistry(shareTokenRegistry).setZone(shareToken, zone);
    }

    function burnWithinZone(address zone, uint256 tokenId) external onlyCouncilMember whenNotPaused nonReentrant {
        if (!IZoneRegistry(zoneRegistry).isZone(zone)) revert UnknownZone();
        address shareToken = IZone(zone).burn(tokenId);
        if (IShareTokenRegistry(shareTokenRegistry).isTradeable(shareToken))
            IShareTokenRegistry(shareTokenRegistry).switchTradeability(shareToken);
        IShareTokenRegistry(shareTokenRegistry).setZone(shareToken, address(0));
        IShareTokenRegistry(shareTokenRegistry).unregisterShareToken(shareToken);
    }

    function switchPauseState() external onlyCouncilMember {
        if (paused()) _unpause();
        else _pause();
    }

    function switchZonePauseState(address zone) external onlyCouncilMember whenNotPaused {
        if (!IZoneRegistry(zoneRegistry).isZone(zone)) revert UnknownZone();
        IZone(zone).switchPauseState();
    }
}
