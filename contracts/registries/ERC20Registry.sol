pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Registry is Ownable {
    mapping(address => bool) public isTradeable;
    mapping(address => mapping(uint256 => address)) public assetTradeEvalutionToken;

    event AssetAllowed(address indexed asset, uint256 indexed assetId);

    constructor(address newOwner) Ownable(newOwner) {}

    function switchAssetTradeability(address asset) external onlyOwner {
        require(asset.code.length > 0, "NOT_A_CONTRACT");
        isTradeable[asset] = !isTradeable[asset];
    }
}
