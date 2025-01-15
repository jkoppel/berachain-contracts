// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MockERC20.sol";

contract MaxGasConsumeERC20 is MockERC20 {
    uint256 loopCount = 1_000_000;

    function setLoopCount(uint256 count) public {
        loopCount = count;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        // Intentionally waste gas by running an excessive loop
        for (uint256 i = 0; i < loopCount; i++) {
            // Empty loop to consume gas
        }
        // Call the normal ERC20 transfer after excessive gas usage
        return super.transfer(recipient, amount);
    }
}
