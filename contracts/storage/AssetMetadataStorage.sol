pragma solidity ^0.8.0;

import {Modifiers} from "../utils/Modifiers.sol";
import {RoleRegistry} from "../registries/RoleRegistry.sol";
import "../libs/Constants.sol";

contract AssetMetadataStorage is Modifiers {
  mapping(uint256 => string) public tokenURI;
  bytes32 public immutable METADATA_UPDATER_ROLE_SUFFIX;
  address public immutable zone;

  constructor(RoleRegistry roleRegistry, address storageAdmin) Modifiers(roleRegistry) {
    METADATA_UPDATER_ROLE_SUFFIX = keccak256(
      bytes(string(abi.encodePacked("lrp-asset-metadata-storage-role-", msg.sender)))
    );
    bytes32 METADATA_UPDATER = keccak256(abi.encodePacked(METADATA_UPDATER_ROLE_PREFIX, METADATA_UPDATER_ROLE_SUFFIX));
    roleRegistry.grantRole(METADATA_UPDATER, storageAdmin);
    zone = msg.sender; // Deployer must be geo-zone contract
  }

  function setTokenURI(uint256 tokenId, string memory uri) external onlyMetadataUpdater(METADATA_UPDATER_ROLE_SUFFIX) {
    // TO DO: Check asset is in zone;
    tokenURI[tokenId] = uri;
  }
}
