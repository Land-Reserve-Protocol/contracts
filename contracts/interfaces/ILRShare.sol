pragma solidity ^0.8.0;

// Market observation per asset
struct Observation {
    uint16 trades; // (Buys + Sells)
    uint256 currentPrice; // Unit price of the asset
    uint16 buyVolume;
    uint16 sellVolume;
    uint256 buyEpsilon;
    uint256 sellEpsilon;
    uint24 momentum;
    uint24 sentiment;
}

interface ILRShare {
    function initialize(uint256) external;
    function mint(address to, uint256 amount) external;
    function observations(
        uint256 index
    )
        external
        view
        returns (
            uint16 trades,
            uint256 currentPrice,
            uint16 buyVolume,
            uint16 sellVolume,
            uint256 buyEpsilon,
            uint256 sellEpsilon,
            uint24 momentum,
            uint24 sentiment
        );
}
