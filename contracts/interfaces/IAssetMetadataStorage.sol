pragma solidity ^0.8.0;

interface IAssetMetadataStorage {
    error OnlyZone();

    function zone() external view returns (address);
    function setTokenURI(uint256, string calldata) external;
    function tokenURI(uint256) external view returns (string memory);

    event TokenURIUpdated(string tokenURI);
}
