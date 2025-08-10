pragma solidity ^0.8.28;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {Modifiers} from './utils/Modifiers.sol';
import {RoleRegistry} from './registries/RoleRegistry.sol';

contract LRP is ERC20, Modifiers {
    constructor(RoleRegistry roleRegistry) ERC20('Land Reserve Protocol', 'LRP') Modifiers() {
        _setRoleRegistry(roleRegistry);
    }

    function mint(address to, uint256 amount) external onlyMinter {
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) external onlyMinter {
        _burn(to, amount);
    }
}
