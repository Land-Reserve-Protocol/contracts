pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/math/Math.sol';
import './Constants.sol' as Constants;

library TradeMath {
    uint24 constant POINT_TWO = 2000; // 0.2% in basis points

    function rawVolumeFactor(
        uint16 volumeAtCurrentTradeIndex,
        uint16 volumeAtPreviousTradeIndex
    ) internal pure returns (uint24 raw) {
        if (volumeAtPreviousTradeIndex == 0) {
            raw = Constants.BASE_NON_NATIVE_UNIT;
        } else {
            uint24 normalizedQuotient = (volumeAtCurrentTradeIndex * Constants.BASE_NON_NATIVE_UNIT) /
                volumeAtPreviousTradeIndex;
            raw = uint24(Math.min(Constants.BASE_NON_NATIVE_UNIT, normalizedQuotient));
        }
    }

    function volumeSmoothingFactorAlpha(uint24 raw) internal pure returns (uint24 alpha) {
        uint24 v = Constants.BASE_NON_NATIVE_UNIT - raw; // raw is always within the range of 0 - 10^4
        alpha = raw + (v * raw);
        if (v > 0) {
            alpha = alpha / Constants.BASE_NON_NATIVE_UNIT;
        }
    }

    function smoothedVolumeFactor(
        uint24 raw,
        uint256 volumeAtPreviousTradeIndex
    ) internal pure returns (uint24 smoothed) {
        uint24 alpha = volumeSmoothingFactorAlpha(raw); // Find factor (alpha)
        uint24 a = (alpha * raw) / Constants.BASE_NON_NATIVE_UNIT;
        uint24 b = (Constants.BASE_NON_NATIVE_UNIT - alpha) * uint24(volumeAtPreviousTradeIndex);
        smoothed = a + b;
    }

    function momentumFactor(
        uint16 numberOfTrades,
        uint256 priceAtPreviousTradeIndex,
        uint24 momentumAtPreviousTradeIndex,
        uint8 priceTokenDecimals
    ) internal pure returns (uint24 momentum) {
        if (priceTokenDecimals == 0) {
            priceTokenDecimals = 18; // Default to 18 decimals if not specified
        }
        uint24 alpha = (uint24(POINT_TWO * numberOfTrades) * Constants.BASE_NON_NATIVE_UNIT) /
            uint24(numberOfTrades + 1);
        uint256 a = (alpha * priceAtPreviousTradeIndex) / 10 ** priceTokenDecimals;
        uint256 b = ((Constants.BASE_NON_NATIVE_UNIT ** 2) - alpha) * momentumAtPreviousTradeIndex;
        b = b / Constants.BASE_NON_NATIVE_UNIT; // Normalize
        momentum = uint24(a + b) / (momentumAtPreviousTradeIndex > 0 ? 10 ** 4 : 1);
    }

    function rawSentiment(
        uint24 k,
        uint256 buyEpsilon,
        uint256 sellEpsilon,
        uint16 buyVolume,
        uint16 sellVolume
    ) internal pure returns (uint24 sentiment) {
        if (k == 0) {
            k = Constants.SENTIMENT_SENSITIVITY_COEFFICIENT; // Default to 0.3 if not specified
        }

        uint256 buys = (buyEpsilon * Constants.BASE_NON_NATIVE_UNIT) / buyVolume;
        uint256 sells = (sellEpsilon * Constants.BASE_NON_NATIVE_UNIT) / sellVolume;

        uint256 delta = buys > sells ? buys - sells : sells - buys; // We need the absolute difference
        uint256 sum = buys + sells;
        if (sum > 0) {
            sentiment = uint24((delta * k) / sum); // Division would normalize the value
        }
    }

    function sentimentSmoothingFactorAlpha(uint24 raw, uint24 min, uint24 max) internal pure returns (uint24 alpha) {
        require(min <= max, 'INVALID_RANGE');
        uint24 v = max - min;
        alpha = min + (v * raw);
        if (v > 0) {
            alpha = alpha / Constants.BASE_NON_NATIVE_UNIT;
        }
    }

    function smoothedSentiment(
        uint24 alpha,
        uint24 raw,
        uint24 sentimentAtPreviousTradeIndex
    ) internal pure returns (uint24 smoothed) {
        uint256 a = alpha * raw;
        uint256 b = (Constants.BASE_NON_NATIVE_UNIT - alpha) * sentimentAtPreviousTradeIndex;
        smoothed = uint24((a + b) / Constants.BASE_NON_NATIVE_UNIT);
    }
}
