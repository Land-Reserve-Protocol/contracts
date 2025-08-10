pragma solidity ^0.8.0;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import '../utils/Modifiers.sol';
import '../interfaces/IShareTokenRegistry.sol';

contract ShareTokenRegistry is Ownable, Modifiers, IShareTokenRegistry {
    mapping(address => bool) public isShareToken;
    mapping(address => bool) public isTradeable;

    event AssetAllowed(address indexed asset, uint256 indexed assetId);

    constructor(address newOwner) Ownable(msg.sender) {
        _transferOwnership(newOwner);
    }

    function registerShareToken(address shareToken) external onlyRegistryUpdater {
        if (isShareToken[shareToken]) revert AlreadyRegistered();
        isShareToken[shareToken] = true;
    }

    function switchTradeability(address shareToken) external onlyRegistryUpdater {
        require(isShareToken[shareToken], 'UNKNOWN_TOKEN');
        isTradeable[shareToken] = !isTradeable[shareToken];
    }

    function setRoleRegistry(address roleRegistry) external onlyCouncilMember {
        require(address(roles) == address(0), 'ROLES_REGISTRY != ZERO_ADDRESS');
        _setRoleRegistry(RoleRegistry(roleRegistry));
    }
}
