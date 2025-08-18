pragma solidity ^0.8.0;

import '@openzeppelin/contracts/proxy/Clones.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import './interfaces/IMarketplace.sol';
import './interfaces/IOrder.sol';
import './interfaces/ILRShare.sol';
import './interfaces/IShareTokenRegistry.sol';
import './utils/Modifiers.sol';
import './registries/RoleRegistry.sol';
import './libs/Constants.sol' as Constants;

contract MarketPlace is Modifiers, IMarketplace, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    address public immutable orderImplementation;
    address public immutable shareTokenRegistry;
    address[] public orders;

    mapping(address => OrderStatus) public status;
    mapping(address => address) public shareTokenForOrder;
    mapping(address => bool) private _isOrder;

    constructor(address _orderImplementation, RoleRegistry roleRegistry, address _shareTokenRegistry) Modifiers() {
        orderImplementation = _orderImplementation;
        shareTokenRegistry = _shareTokenRegistry;
        _setRoleRegistry(roleRegistry);
    }

    function createOrder(
        address shareToken,
        uint8 orderType,
        uint64 volume,
        uint256 unitAmount
    ) external whenNotPaused nonReentrant returns (address orderId) {
        if (!IShareTokenRegistry(shareTokenRegistry).isShareToken(shareToken)) revert UnknownShareToken();
        if (!IShareTokenRegistry(shareTokenRegistry).isTradeable(shareToken)) revert NonTradeableShareToken();
        bytes32 salt = keccak256(abi.encodePacked(shareToken, orderType, block.timestamp));
        orderId = Clones.cloneDeterministic(orderImplementation, salt);

        OrderType ot = OrderType(orderType);
        IOrder(orderId).initialize(ot, unitAmount, volume, msg.sender, shareToken);

        if (ot == OrderType.BUY) {
            address token = ILRShare(shareToken).peggedAsset();
            uint256 amount = (unitAmount * volume) / Constants.BASE_NON_NATIVE_UNIT;
            IERC20(token).safeTransferFrom(msg.sender, orderId, amount);
        } else if (ot == OrderType.SELL) {
            uint256 amount = (volume * 10 ** Constants.BASE_DECIMALS) / Constants.BASE_NON_NATIVE_UNIT;
            IERC20(shareToken).safeTransferFrom(msg.sender, orderId, amount);
        } else revert InvalidOrderType();

        _isOrder[orderId] = true;
        shareTokenForOrder[orderId] = shareToken;
        status[orderId] = OrderStatus.PENDING;
        orders.push(orderId);
        emit OrderCreated(orderId, orderType, volume, shareToken, unitAmount);
    }

    function fulfillOrder() external {
        require(_isOrder[msg.sender], 'INVALID_CALLER');
        require(status[msg.sender] == OrderStatus.PENDING, 'ORDER_NOT_PENDING');
        status[msg.sender] = OrderStatus.FULFILLED;
    }

    function cancelOrder() external {
        require(_isOrder[msg.sender], 'INVALID_CALLER');
        require(status[msg.sender] == OrderStatus.PENDING, 'ORDER_NOT_PENDING');
        status[msg.sender] = OrderStatus.CANCELLED;
    }

    function switchPauseState() external onlyCouncilMember {
        if (paused()) _unpause();
        else _pause();
    }

    function ordersLength() external view returns (uint256) {
        return orders.length;
    }

    function allOrders() external view returns (address[] memory) {
        return orders;
    }
}
