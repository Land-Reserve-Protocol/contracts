pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./utils/Modifiers.sol";
import "./registries/RoleRegistry.sol";
import "./interfaces/IZone.sol";

contract Actions is Modifiers, Pausable, ReentrancyGuard {
    address public immutable zoneImplementation;
    address public immutable lrShareImplementation;

    mapping(address => bool) private _isZone;

    error UnknownZone();

    constructor(address _zoneImplementation, address _lrShareImplementation, RoleRegistry roleRegistry) Modifiers() {
        zoneImplementation = _zoneImplementation;
        lrShareImplementation = _lrShareImplementation;
        _setRoleRegistry(roleRegistry);
    }

    function deployZone(
        string memory name,
        string memory symbol,
        uint24 lat,
        uint24 lng,
        address admin
    ) external onlyCouncilMember whenNotPaused nonReentrant returns (address zone) {
        bytes32 salt = keccak256(abi.encodePacked(name, symbol, lat, lng));
        zone = Clones.cloneDeterministic(zoneImplementation, salt);
        IZone(zone).initialize(name, symbol, lat, lng, address(roles), admin, lrShareImplementation);
        _isZone[zone] = true;
    }

    function mintWithinZone(
        address zone,
        address to,
        uint256 totalShares,
        string memory tokenURI
    ) external onlyCouncilMember whenNotPaused nonReentrant {
        if (!_isZone[zone]) revert UnknownZone();
        (uint256 tokenId, address shareToken) = IZone(zone).mint(to, totalShares, tokenURI);
        // To Do: Register share token
    }
}
