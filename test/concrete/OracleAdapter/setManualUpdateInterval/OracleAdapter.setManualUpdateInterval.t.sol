// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

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

        vm.prank(deployer);
        vm.expectEmit(true, true, true, true);
        emit IOracleAdapter.ManualUpdateIntervalSet(newInterval, deployer);

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
        vm.prank(deployer);
        vm.expectRevert(Errors.ZeroAmount.selector);
        oracle.setManualUpdateInterval(0);
    }
}
