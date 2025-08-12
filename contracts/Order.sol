pragma solidity ^0.8.0;

import './interfaces/IOrder.sol';

contract Order is IOrder {
    OrderType public orderType;
    uint256 public amount;
    address public account;
    address public factory;
    address public lrShare;
    bool public fulfilled;

    function initialize(OrderType _orderType, uint256 _amount, address _account, address _lrShare) external {
        if (factory != address(0)) revert AlreadyInitialized();
        factory = msg.sender;
        orderType = _orderType;
        amount = _amount;
        account = _account;
        lrShare = _lrShare;
        fulfilled = false;
    }

    function fulfill() external override {
        require(!fulfilled, 'ALREADY_FULFILLED');
        if (orderType == OrderType.BUY) {
            //
        } else {}

        fulfilled = true;
    }
}
