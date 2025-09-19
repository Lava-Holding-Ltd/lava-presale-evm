// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { INITIAL_ADMIN } from "script/lib/DataStore.sol";
import { Errors } from "src/lib/Errors.sol";
import { IOracleAdapter } from "src/interfaces/IOracleAdapter.sol";

import { ICOSaleTest } from "test/ICOSaleTest.sol";

contract OracleAdapterSetManualUpdateIntervalTest is ICOSaleTest {
    function setUp() public {
        fixture();
    }

    function test_whenOwnerSetsNonZeroInterval_success() external {
        uint256 newInterval = 6 hours;

        assertEq(oracle.manualUpdateInterval(), 4200);

        vm.prank(INITIAL_ADMIN);
        vm.expectEmit(true, true, true, true);
        emit IOracleAdapter.ManualUpdateIntervalSet(newInterval, INITIAL_ADMIN);

        oracle.setManualUpdateInterval(newInterval);

        assertEq(oracle.manualUpdateInterval(), newInterval);
    }

    function test_whenNonOwnerCalls_revert() external {
        assertEq(oracle.manualUpdateInterval(), 4200);

        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, bob));
        oracle.setManualUpdateInterval(3 hours);

        assertEq(oracle.manualUpdateInterval(), 4200);
    }

    function test_whenIntervalIsZero_revert() external {
        vm.prank(INITIAL_ADMIN);
        vm.expectRevert(Errors.ZeroAmount.selector);
        oracle.setManualUpdateInterval(0);
    }
}
