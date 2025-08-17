pragma solidity ^0.8.0;

enum OrderStatus {
    PENDING,
    FULFILLED,
    CANCELLED
}

interface IMarketplace {
    error InvalidOrderType();

    function createOrder(
        address shareToken,
        uint8 orderType,
        uint24 volume,
        uint256 unitAmount
    ) external returns (address orderId);
    function cancelOrder() external;
    function fulfillOrder() external;
    function status(address) external view returns (OrderStatus);
    function orders(uint256) external view returns (address);

    event OrderCreated(
        address indexed orderId,
        uint8 indexed orderType,
        uint24 volume,
        address indexed shareToken,
        uint256 unitAmount
    );
}
