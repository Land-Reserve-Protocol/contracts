pragma solidity ^0.8.0;

interface IZone {
    error AlreadyInitialized();
    error OnlyFactory();

    function tokenId() external view returns (uint256);
    function metadata() external view returns (uint24, uint24, uint256);
    function factory() external view returns (address);
    function shareToken(uint256) external view returns (address);
    function initialize(string memory, string memory, uint24, uint24, address, address, address) external;
    function mint(address, uint256, string memory) external returns (uint256, address);

    event Mint(uint256 indexed tokenId, address indexed shareToken, string metadataURI);
    event Initialize(string name, string symbol, uint24 lat, uint24 lng, address admin);
}
