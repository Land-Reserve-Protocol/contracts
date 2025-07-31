pragma solidity ^0.8.0;

library ZKSnark {
    function derivePrimeNumber() internal view returns (uint256) {
        uint256 possible 
    }
    function computeCommitment() internal view returns (bytes32 _proof) {
        _proof = keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender));
    }

    function verifyCommitment() internal view returns (bytes32) {}
}
