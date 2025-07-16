pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LRShare is ERC20 {
    address public zone;
    uint256 public assetId;
    address public peggedAsset;

    string private _name;
    string private _symbol;

    constructor() ERC20("", "") {}

    function initialize(address _zone, uint256 _assetId) external {
        require(zone == address(0), "ALREADY_INITIALIZED");
        zone = _zone;
        assetId = _assetId;

        _name = string(abi.encodePacked("Land Reserve Share: ", "", _assetId));
        _symbol = string(abi.encodePacked("LRS: ", "", _assetId));
    }

    function mint(address to, uint256 amount) external {
        require(totalSupply() == 0, "ALREADY_MINTED");
        require(msg.sender == zone, "ONLY_ZONE_CAN_MINT");
        _mint(to, amount);
    }
}
