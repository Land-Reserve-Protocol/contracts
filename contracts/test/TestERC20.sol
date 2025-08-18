pragma solidity ^0.8.0;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract TestERC20 is ERC20 {
    constructor() ERC20('Test USDT', 'TUSDT') {
        _mint(msg.sender, 10000000000000);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}
