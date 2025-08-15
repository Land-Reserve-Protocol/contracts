pragma solidity ^0.8.0;

// Ecosystem roles (may change)
bytes32 constant MINTER_ROLE = keccak256('MINTER');
bytes32 constant COUNCIL_MEMBER_ROLE = keccak256('COUNCIL_MEMBER');
bytes32 constant RELAYER_ROLE = keccak256('RELAYER');
bytes32 constant ROLES_GOVERNOR_ROLE = keccak256('ROLES_GOVERNOR'); // Sets roles
bytes32 constant REGISTRY_UPDATER_ROLE = keccak256('REGISTRY_UPDATER');
// Other roles (may change)
bytes32 constant METADATA_UPDATER_ROLE_PREFIX = keccak256('METADATA_UPDATER_PREFIX');
// Math
uint24 constant BASE_NON_NATIVE_UNIT = 10000;
// Category multiplier deltas
uint24 constant RESIDENTIAL = 0; // 0.0
uint24 constant COMMERCIAL = 4000; // 0.4
uint24 constant INDUSTRIAL = 6000; //0.6 (until changes are requested)
uint24 constant AGRICULTURAL = 1000; // 0.1
// Other constants
uint24 constant SENTIMENT_SENSITIVITY_COEFFICIENT = 3000; // 0.3 in basis points
uint24 constant ZER0 = 0;
