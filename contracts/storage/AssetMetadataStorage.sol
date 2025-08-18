pragma solidity ^0.8.0;

import {RoleRegistry} from '../registries/RoleRegistry.sol';
import {IAssetMetadataStorage} from '../interfaces/IAssetMetadataStorage.sol';
import {IZone} from '../interfaces/IZone.sol';
import '../libs/Constants.sol';

contract AssetMetadataStorage is IAssetMetadataStorage {
    mapping(uint256 => string) public tokenURI;
    address public immutable zone;

    constructor() {
        zone = msg.sender; // Deployer must be geo-zone contract
    }

    function setTokenURI(uint256 tokenId, string memory uri) external {
        if (msg.sender != zone) revert OnlyZone();
        require(tokenId <= IZone(zone).tokenId(), 'TOKEN_ID');
        require(IZone(zone).exists(tokenId), 'TOKEN_DOES_NOT_EXIST');
        tokenURI[tokenId] = uri;
        emit TokenURIUpdated(uri);
    }
}
