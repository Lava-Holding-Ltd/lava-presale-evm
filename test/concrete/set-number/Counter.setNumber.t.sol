// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { CounterTest } from "test/CounterTest.sol";

contract CountersetNumber is CounterTest {
    function setUp() external {
        fixture();
    }

    function test_WhenUserTriggerSetNumber(uint256 x) external {
        // it state updated
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
