pragma solidity ^0.8.0;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import '../utils/Modifiers.sol';
import '../interfaces/IShareTokenRegistry.sol';

contract ShareTokenRegistry is Ownable, Modifiers, IShareTokenRegistry {
    mapping(address => bool) public isShareToken;
    mapping(address => bool) public isTradeable;
    mapping(address => address) public zone;

    address[] public shareTokens;

    constructor(address newOwner, RoleRegistry _roles) Ownable(msg.sender) Modifiers() {
        _transferOwnership(newOwner);
        _setRoleRegistry(_roles);
    }

    function registerShareToken(address shareToken) external onlyRegistryUpdater {
        if (isShareToken[shareToken]) revert AlreadyRegistered();
        isShareToken[shareToken] = true;
        shareTokens.push(shareToken);
    }

    function unregisterShareToken(address shareToken) external onlyRegistryUpdater {
        if (!isShareToken[shareToken]) revert NotRegistered();
        isShareToken[shareToken] = false;
    }

    function switchTradeability(address shareToken) external onlyRegistryUpdater {
        require(isShareToken[shareToken], 'UNKNOWN_TOKEN');
        isTradeable[shareToken] = !isTradeable[shareToken];
    }

    function setZone(address shareToken, address zoneAddress) external onlyRegistryUpdater {
        require(isShareToken[shareToken], 'UNKNOWN_TOKEN');
        if (zone[shareToken] != address(0) && zoneAddress != address(0)) revert AlreadyRegistered();
        zone[shareToken] = zoneAddress;
    }

    function allShareTokens() external view returns (address[] memory) {
        return shareTokens;
    }

    function allShareTokensLength() external view returns (uint256) {
        return shareTokens.length;
    }
}
