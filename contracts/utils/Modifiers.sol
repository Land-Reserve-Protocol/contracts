pragma solidity ^0.8.0;

import {RoleRegistry} from "../registries/RoleRegistry.sol";
import {Roles} from "../libs/Roles.sol";
import "../libs/Constants.sol";

abstract contract Modifiers {
  using Roles for RoleRegistry;

  RoleRegistry public immutable roles;

  error DoesNotHaveRole(address, bytes32);

  constructor(RoleRegistry _roles) {
    roles = _roles;
  }

  modifier onlyMinter() {
    if (!roles.accountHasSingleRole(msg.sender, MINTER_ROLE)) {
      revert DoesNotHaveRole(msg.sender, MINTER_ROLE);
    }
    _;
  }

  modifier onlyCouncilMember() {
    if (!roles.accountHasSingleRole(msg.sender, COUNCIL_MEMBER_ROLE)) {
      revert DoesNotHaveRole(msg.sender, COUNCIL_MEMBER_ROLE);
    }
    _;
  }

  modifier onlyMetadataUpdater(bytes32 suffix) {
    bytes32 METADATA_UPDATER = keccak256(abi.encodePacked(METADATA_UPDATER_ROLE_PREFIX, suffix));
    if (!roles.accountHasSingleRole(msg.sender, METADATA_UPDATER)) {
      revert DoesNotHaveRole(msg.sender, METADATA_UPDATER);
    }
    _;
  }
}
