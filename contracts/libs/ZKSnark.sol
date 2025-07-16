pragma solidity ^0.8.0;

library ZKSnark {
    function generatePolynomial() internal view returns (bytes32 _proof) {
        _proof = keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender));
    }
}
