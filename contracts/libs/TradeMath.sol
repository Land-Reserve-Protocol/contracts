pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/math/Math.sol';
import './Constants.sol' as Constants;

library TradeMath {
    uint64 constant POINT_TWO = 2000; // 0.2% in basis points

    function rawVolumeFactor(
        uint64 volumeAtCurrentTradeIndex,
        uint64 volumeAtPreviousTradeIndex
    ) internal pure returns (uint64 raw) {
        if (volumeAtPreviousTradeIndex == 0) {
            raw = Constants.BASE_NON_NATIVE_UNIT;
        } else {
            uint64 normalizedQuotient = (volumeAtCurrentTradeIndex * Constants.BASE_NON_NATIVE_UNIT) /
                volumeAtPreviousTradeIndex;
            raw = uint64(Math.min(Constants.BASE_NON_NATIVE_UNIT, normalizedQuotient));
        }
    }

    function volumeSmoothingFactorAlpha(uint64 raw) internal pure returns (uint64 alpha) {
        uint64 v = Constants.BASE_NON_NATIVE_UNIT - raw; // raw is always within the range of 0 - 10^4
        alpha = raw + (v * raw);
        if (v > 0) {
            alpha = alpha / Constants.BASE_NON_NATIVE_UNIT;
        }
    }

    function smoothedVolumeFactor(
        uint64 raw,
        uint64 volumeAtPreviousTradeIndex
    ) internal pure returns (uint64 smoothed) {
        uint64 alpha = volumeSmoothingFactorAlpha(raw); // Find factor (alpha)
        uint64 a = (alpha * raw) / Constants.BASE_NON_NATIVE_UNIT;
        uint64 b = (Constants.BASE_NON_NATIVE_UNIT - alpha) * volumeAtPreviousTradeIndex;
        smoothed = a + b;
    }

    function momentumFactor(
        uint64 numberOfTrades,
        uint256 priceAtPreviousTradeIndex,
        uint64 momentumAtPreviousTradeIndex,
        uint8 priceTokenDecimals
    ) internal pure returns (uint64 momentum) {
        if (priceTokenDecimals == 0) {
            priceTokenDecimals = 18; // Default to 18 decimals if not specified
        }
        uint64 alpha = (uint64(POINT_TWO * numberOfTrades) * Constants.BASE_NON_NATIVE_UNIT) /
            uint64(numberOfTrades + 1);
        uint256 a = (alpha * priceAtPreviousTradeIndex) / 10 ** priceTokenDecimals;
        uint256 b = ((Constants.BASE_NON_NATIVE_UNIT ** 2) - alpha) * momentumAtPreviousTradeIndex;
        b = b / Constants.BASE_NON_NATIVE_UNIT; // Normalize
        momentum = uint64(a + b) / (momentumAtPreviousTradeIndex > 0 ? 10 ** 4 : 1);
    }

    function rawSentiment(
        uint64 k,
        uint256 buyEpsilon,
        uint256 sellEpsilon,
        uint64 buyVolume,
        uint64 sellVolume
    ) internal pure returns (uint64 sentiment) {
        if (k == 0) {
            k = Constants.SENTIMENT_SENSITIVITY_COEFFICIENT; // Default to 0.3 if not specified
        }

        uint256 buys = buyVolume > 0 ? buyEpsilon / buyVolume : 0;
        uint256 sells = sellVolume > 0 ? sellEpsilon / sellVolume : 0;

        uint256 delta = buys > sells ? buys - sells : sells - buys; // We need the absolute difference
        uint256 sum = buys + sells;
        if (sum > 0) {
            sentiment = uint64((delta * k) / sum); // Division would normalize the value
        }
    }

    function sentimentSmoothingFactorAlpha(uint64 raw, uint64 min, uint64 max) internal pure returns (uint64 alpha) {
        require(min <= max, 'INVALID_RANGE');
        uint64 v = max - min;
        alpha = min + (v * raw);
        if (v > 0) {
            alpha = alpha / Constants.BASE_NON_NATIVE_UNIT;
        }
    }

    function smoothedSentiment(
        uint64 alpha,
        uint64 raw,
        uint64 sentimentAtPreviousTradeIndex
    ) internal pure returns (uint64 smoothed) {
        uint256 a = alpha * raw;
        uint256 b = (Constants.BASE_NON_NATIVE_UNIT - alpha) * sentimentAtPreviousTradeIndex;
        smoothed = uint64((a + b) / Constants.BASE_NON_NATIVE_UNIT);
    }
}
