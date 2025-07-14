pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import "../libs/Constants.sol";

contract RoleRegistry is Ownable, AccessControl {
  constructor(address newOwner) Ownable(newOwner) AccessControl() {
    _setRoleAdmin(MINTER_ROLE, ROLES_GOVERNOR_ROLE);
    _setRoleAdmin(COUNCIL_MEMBER_ROLE, ROLES_GOVERNOR_ROLE);
    _setRoleAdmin(RELAYER_ROLE, ROLES_GOVERNOR_ROLE);

    // Make new owner the governor
    _grantRole(ROLES_GOVERNOR_ROLE, newOwner);
  }

  function setRoleAdmin(bytes32 role, bytes32 admin) external onlyOwner {
    _setRoleAdmin(role, admin);
  }
}
