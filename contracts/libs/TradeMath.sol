pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/math/Math.sol';
import './Constants.sol';

library TradeMath {
    uint24 constant POINT_TWO = 2000; // 0.2% in basis points

    function rawVolumeFactor(
        uint256 volumeAtCurrentTradeIndex,
        uint256 volumeAtPreviousTradeIndex
    ) internal pure returns (uint24 raw) {
        if (volumeAtPreviousTradeIndex == 0) {
            raw = BASE_NON_NATIVE_UNIT;
        } else {
            uint24 normalizedQuotient = uint24(
                (volumeAtCurrentTradeIndex * uint256(BASE_NON_NATIVE_UNIT)) / volumeAtPreviousTradeIndex
            );
            raw = uint24(Math.min(BASE_NON_NATIVE_UNIT, normalizedQuotient));
        }
    }

    function smoothingFactorAlpha(uint24 raw) internal pure returns (uint24 alpha) {
        uint24 v = BASE_NON_NATIVE_UNIT - raw; // raw is always within the range of 0 - 10^4
        alpha = raw + v * raw;
        if (v > 0) {
            alpha = alpha / BASE_NON_NATIVE_UNIT;
        }
    }

    function smoothedVolumeFactor(
        uint24 raw,
        uint256 volumeAtPreviousTradeIndex
    ) internal pure returns (uint24 smoothed) {
        uint24 alpha = smoothingFactorAlpha(raw); // Find factor (alpha)
        uint24 a = (alpha * raw) / BASE_NON_NATIVE_UNIT;
        uint24 b = (BASE_NON_NATIVE_UNIT - alpha) * uint24(volumeAtPreviousTradeIndex);
        smoothed = a + b;
    }

    function momentumFactor(
        uint256 numberOfTrades,
        uint256 priceAtPreviousTradeIndex,
        uint24 momentumAtPreviousTradeIndex,
        uint8 priceTokenDecimals
    ) internal pure returns (uint24 momentum) {
        uint24 alpha = (uint24(POINT_TWO * numberOfTrades) * BASE_NON_NATIVE_UNIT) / uint24(numberOfTrades + 1);
        uint256 a = (alpha * priceAtPreviousTradeIndex) / 10 ** priceTokenDecimals;
        uint256 b = ((BASE_NON_NATIVE_UNIT ** 2) - alpha) * momentumAtPreviousTradeIndex;
        b = b / BASE_NON_NATIVE_UNIT; // Normalize
        momentum = uint24(a + b) / (momentumAtPreviousTradeIndex > 0 ? 10 ** 4 : 1);
    }
}
