pragma solidity ^0.8.0;

import "./Constants.sol";

library AssetMath {
    // Weights for each factor. Each value must have a factor of 10^4 (i.e human value * 10^4) to bypass Solidity's inability to handle floating point numbers
    struct AssetWeights {
        uint24 w0;
        uint24 w1;
        uint24 w2;
        uint24 w3;
    }

    /// @notice Derives market price
    /// @dev Each uint24 item is a value with a factor of 10^4
    /// @param basePrice Base price in token units
    /// @param currentMarketValue Market value in token units
    /// @param weights Factor weights
    /// @return _marketPrice Market price in token units
    function marketPrice(
        uint256 basePrice,
        uint256 currentMarketValue,
        AssetWeights memory weights,
        uint24 tradeVolumeFactor,
        uint24 areaVolumeFactor,
        uint24 categoryMultiplierDelta,
        uint24 manualModifier,
        uint24 sensitivityCoefficient
    ) internal pure returns (uint256 _marketPrice) {
        require(weights.w0 + weights.w1 + weights.w2 + weights.w3 == BASE_NON_NATIVE_UNIT, "TW != 1"); // Total weights must be equal to 1.
        uint256 accumWeights = weights.w0 * weights.w1 * weights.w2 * weights.w3; // Accumulated weights with a factor of 10^16
        uint256 marketValuePressureRatio = (currentMarketValue * BASE_NON_NATIVE_UNIT) / basePrice;
        uint256 factors = accumWeights *
            (tradeVolumeFactor + areaVolumeFactor + marketValuePressureRatio + categoryMultiplierDelta);
        _marketPrice = 
            (basePrice * (1 + (sensitivityCoefficient * factors) + manualModifier)) /
            (manualModifier > 0 ? 1e28 : 1e24); // Divide by 10^24 to cancel out exponent of `factors` and `sensitivityCoefficient` or 10^28 if modifier is greater than 0
    }
}
