pragma solidity ^0.8.0;

interface IZone {
    error AlreadyInitialized();
    error OnlyFactory();

    function tokenId() external view returns (uint256);
    function metadata() external view returns (uint24, uint24, uint256);
    function factory() external view returns (address);
    function shareToken(uint256) external view returns (address);

    event Mint(uint256 indexed tokenId, address indexed shareToken, string metadataURI);
}
