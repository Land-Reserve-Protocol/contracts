pragma solidity ^0.8.0;

// Market observation per asset
struct Observation {
    uint256 trades; // (Buys + Sells)
    uint256 currentPrice;
    uint256 buyVolume;
    uint256 sellVolume;
    uint256 buyPrice;
    uint256 sellPrice;
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
            uint256 trades,
            uint256 currentPrice,
            uint256 buyVolume,
            uint256 sellVolume,
            uint256 buyPrice,
            uint256 sellPrice
        );
}
