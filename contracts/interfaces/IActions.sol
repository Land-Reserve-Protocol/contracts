pragma solidity ^0.8.0;

interface IActions {
    event NewZone(
        address indexed zone,
        string indexed name,
        string indexed symbol,
        uint24 lat,
        uint24 lng,
        address admin
    );
}
