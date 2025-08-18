pragma solidity ^0.8.0;

// Asset type
enum AssetType {
    Residential,
    Commercial,
    Industrial,
    Agricultural
}

// Market observation per asset
struct Observation {
    uint64 trades; // (Buys + Sells)
    uint256 currentPrice; // Unit price of the asset
    uint64 buyVolume;
    uint64 sellVolume;
    uint256 buyEpsilon;
    uint256 sellEpsilon;
    uint64 momentum;
    uint64 sentiment;
}

interface ILRShare {
    function peggedAsset() external view returns (address);
    function peggedAssetDecimals() external view returns (uint8);
    function initialize(uint256, address, uint64[4] memory, AssetType) external;
    function mint(address to, uint256 amount) external;
    function burn(uint256 amount) external;
    function updateMarketFactors(uint64 buyVolume, uint64 sellVolume, uint256 buyPrice, uint256 sellPrice) external;
    function observations(
        uint256 index
    )
        external
        view
        returns (
            uint64 trades,
            uint256 currentPrice,
            uint64 buyVolume,
            uint64 sellVolume,
            uint256 buyEpsilon,
            uint256 sellEpsilon,
            uint64 momentum,
            uint64 sentiment
        );
    function observationsLength() external view returns (uint256);
    function lastObservationUpdateTime() external view returns (uint256);
}
