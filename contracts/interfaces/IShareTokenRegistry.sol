pragma solidity ^0.8.0;

interface IShareTokenRegistry {
    error AlreadyRegistered();

    function registerShareToken(address shareToken) external;
    function switchTradeability(address shareToken) external;
    function setZone(address, address) external;
    function isShareToken(address) external view returns (bool);
    function isTradeable(address) external view returns (bool);
    function zone(address) external view returns (address);
}
