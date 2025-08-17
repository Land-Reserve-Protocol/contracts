pragma solidity ^0.8.0;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import '../utils/Modifiers.sol';
import '../interfaces/IZoneRegistry.sol';

contract ZoneRegistry is Ownable, Modifiers, IZoneRegistry {
    mapping(address => bool) public isZone;
    address[] public zones;

    constructor(address newOwner, RoleRegistry _roles) Ownable(msg.sender) Modifiers() {
        _transferOwnership(newOwner);
        _setRoleRegistry(_roles);
    }

    function registerZone(address zone) external onlyRegistryUpdater {
        if (isZone[zone]) revert AlreadyRegistered();
        isZone[zone] = true;
        zones.push(zone);
    }

    function allZones() external view returns (address[] memory) {
        return zones;
    }

    function zonesLength() external view returns (uint256) {
        return zones.length;
    }
}
