pragma solidity ^0.8.0;

interface IShareTokenRegistry {
    error AlreadyRegistered();

    function registerShareToken(address shareToken) external;
    function switchTradeability(address shareToken) external;
    function isShareToken(address) external view returns (bool);
    function isTradeable(address) external view returns (bool);
}
