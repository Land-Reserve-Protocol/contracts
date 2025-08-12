pragma solidity ^0.8.0;

enum OrderType {
    BUY,
    SELL
}

interface IOrder {
    error AlreadyInitialized();

    function initialize(OrderType orderType, uint256 amount, address account, address lrShare) external;
    function fulfill() external;
    function fulfilled() external view returns (bool);
}
