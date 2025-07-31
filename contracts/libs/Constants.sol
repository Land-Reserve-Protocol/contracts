pragma solidity ^0.8.0;

// Ecosystem roles (may change)
bytes32 constant MINTER_ROLE = keccak256("MINTER");
bytes32 constant COUNCIL_MEMBER_ROLE = keccak256("COUNCIL_MEMBER");
bytes32 constant RELAYER_ROLE = keccak256("RELAYER");
bytes32 constant ROLES_GOVERNOR_ROLE = keccak256("ROLES_GOVERNOR"); // Sets roles
// Other roles (may change)
bytes32 constant METADATA_UPDATER_ROLE_PREFIX = keccak256("METADATA_UPDATER_PREFIX");
// Math
uint24 constant BASE_NON_NATIVE_UNIT = 10000;
