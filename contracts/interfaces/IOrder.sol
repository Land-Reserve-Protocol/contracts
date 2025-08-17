pragma solidity ^0.8.0;

enum OrderType {
    BUY,
    SELL
}

interface IOrder {
    error AlreadyInitialized();

    function initialize(
        OrderType orderType,
        uint256 unitAmount,
        uint24 volume,
        address account,
        address shareToken
    ) external;
    function fulfill() external;
    function cancel() external;
    function fulfilled() external view returns (bool);
    function shareToken() external view returns (address);

    event Fulfilled(uint256 indexed timestamp);
    event Cancelled(uint256 indexed timestamp);
}
