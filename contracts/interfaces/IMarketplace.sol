pragma solidity ^0.8.0;

enum OrderStatus {
    PENDING,
    FULFILLED,
    CANCELLED
}

interface IMarketplace {
    error InvalidOrderType();
    error UnknownShareToken();
    error NonTradeableShareToken();

    function createOrder(
        address shareToken,
        uint8 orderType,
        uint64 volume,
        uint256 unitAmount
    ) external returns (address orderId);
    function cancelOrder() external;
    function fulfillOrder() external;
    function status(address) external view returns (OrderStatus);
    function orders(uint256) external view returns (address);
    function ordersLength() external view returns (uint256);
    function allOrders() external view returns (address[] memory);
    function shareTokenForOrder(address) external view returns (address);

    event OrderCreated(
        address indexed orderId,
        uint8 indexed orderType,
        uint64 volume,
        address indexed shareToken,
        uint256 unitAmount
    );
}
