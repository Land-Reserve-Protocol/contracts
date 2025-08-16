pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import './interfaces/IOrder.sol';
import './interfaces/ILRShare.sol';
import './libs/Constants.sol' as Constants;

contract Order is IOrder {
    using SafeERC20 for IERC20;

    OrderType public orderType;
    uint256 public unitAmount;
    uint24 public volume;
    address public account;
    address public factory;
    address public shareToken;
    bool public fulfilled;

    function initialize(
        OrderType _orderType,
        uint256 _unitAmount,
        uint24 _volume,
        address _account,
        address _shareToken
    ) external {
        if (factory != address(0)) revert AlreadyInitialized();
        factory = msg.sender;
        orderType = _orderType;
        unitAmount = _unitAmount;
        account = _account;
        shareToken = _shareToken;
        volume = _volume;
        fulfilled = false;
    }

    function fulfill() external override {
        require(!fulfilled, 'ALREADY_FULFILLED');
        require(msg.sender != account, 'CANNOT_FULFILL_SELF');
        address token = ILRShare(shareToken).peggedAsset();

        if (orderType == OrderType.BUY) {
            uint256 transferable = (volume * 10 ** Constants.BASE_DECIMALS) / Constants.BASE_NON_NATIVE_UNIT; // Normalize to 18 decimals
            // Transfer shares to account
            IERC20(shareToken).safeTransferFrom(msg.sender, account, transferable); // It is expected that the caller has approved the transfer
            uint256 amount = (unitAmount * volume) / Constants.BASE_NON_NATIVE_UNIT; // Normalize to token decimals
            // Transfer asset token to the seller
            IERC20(token).safeTransfer(msg.sender, amount);
            // Update market factor for share token
            ILRShare(shareToken).updateMarketFactors(volume, Constants.ZER0, unitAmount, Constants.ZERO);
            // Send back the remaining token to the buyer
            uint256 remaining = IERC20(token).balanceOf(address(this));
            if (remaining > 0) IERC20(token).safeTransfer(account, remaining);
        } else if (orderType == OrderType.SELL) {
            // Transfer shares from account to the caller
            uint256 transferable = (volume * 10 ** Constants.BASE_DECIMALS) / Constants.BASE_NON_NATIVE_UNIT; // Normalize to 18 decimals
            IERC20(shareToken).safeTransfer(msg.sender, transferable); // It is expected that the order creator has approved the transfer
            // Transfer asset token to the seller
            uint256 amount = (unitAmount * transferable) / 10 ** Constants.BASE_DECIMALS; // Normalize to token decimals
            IERC20(token).safeTransferFrom(msg.sender, account, amount);
            // Update market factor for share token
            IERC20(shareToken).updateMarketFactors(Constants.ZERO, volume, Constants.ZER0, unitAmount);
            // Send back the remaining shares to the seller
            uint256 remaining = IERC20(shareToken).balanceOf(address(this));
            if (remaining > 0) IERC20(shareToken).safeTransfer(account, remaining);
        } else revert('INVALID_ORDER_TYPE');

        fulfilled = true;
        emit Fulfilled(block.timestamp);
    }
}
