pragma solidity ^0.8.0;

import {RoleRegistry} from "../registries/RoleRegistry.sol";

library Roles {
    function accountHasSingleRole(
        RoleRegistry roleRegistry,
        address account,
        bytes32 role
    ) internal view returns (bool _hasRole) {
        _hasRole = roleRegistry.hasRole(role, account);
    }

    function accountHasEveryRole(
        RoleRegistry roleRegistry,
        address account,
        bytes32[] memory roles
    ) internal view returns (bool _hasEveryRole) {
        _hasEveryRole = true;
        for (uint i; i < roles.length; i++) {
            bytes32 role = roles[i];
            if (!roleRegistry.hasRole(role, account)) {
                _hasEveryRole = false;
                break;
            }
        }
    }

    function accountsHaveSingleRole(
        RoleRegistry roleRegistry,
        address[] memory accounts,
        bytes32 role
    ) internal view returns (bool _haveRole) {
        _haveRole = true;
        for (uint i; i < accounts.length; i++) {
            address account = accounts[i];
            if (!roleRegistry.hasRole(role, account)) {
                _haveRole = false;
                break;
            }
        }
    }

    function accountsHaveEveryRole(
        RoleRegistry roleRegistry,
        address[] memory accounts,
        bytes32[] memory roles
    ) internal view returns (bool _haveEveryRole) {
        require(accounts.length == roles.length, "DIFF_LENGTH");
        _haveEveryRole = true;
        for (uint i; i < accounts.length; i++) {
            bool breakOuterLoop = false;
            for (uint j; j < roles.length; j++) {
                if (!roleRegistry.hasRole(roles[j], accounts[i])) {
                    _haveEveryRole = false;
                    breakOuterLoop = true;
                    break;
                }
            }
            if (breakOuterLoop) {
                break;
            }
        }
    }

    function accountsHaveEachRoles(
        RoleRegistry roleRegistry,
        address[] memory accounts,
        bytes32[][] memory roles
    ) internal view returns (bool _hasCorrespondingRoles) {
        require(accounts.length == roles.length, "DIFF_LENGTH");
        _hasCorrespondingRoles = true;
        for (uint i; i < accounts.length; i++) {
            bool breakOuterLoop = false;
            bytes32[] memory _roles = roles[i];
            for (uint j; j < _roles.length; j++) {
                if (!roleRegistry.hasRole(_roles[j], accounts[i])) {
                    _hasCorrespondingRoles = false;
                    breakOuterLoop = true;
                    break;
                }
            }

            if (breakOuterLoop) {
                break;
            }
        }
    }
}
