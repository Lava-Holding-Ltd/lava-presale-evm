// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { CounterTest } from "test/CounterTest.sol";

contract Counterincrement is CounterTest {
    function setUp() external {
        fixture();
    }

    function test_WhenUserTriggerIncrement() external {
        // it state updated
        counter.increment();
        assertEq(counter.number(), 1);
    }
}
