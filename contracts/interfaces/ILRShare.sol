pragma solidity ^0.8.0;

interface ILRShare {
    function initialize(uint256) external;
    function mint(address to, uint256 amount) external;
}
