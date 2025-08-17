pragma solidity ^0.8.0;

interface IZoneRegistry {
    error AlreadyRegistered();
    function registerZone(address zone) external;
    function isZone(address) external view returns (bool);
}
