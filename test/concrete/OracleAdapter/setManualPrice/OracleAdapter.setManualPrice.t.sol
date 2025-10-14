// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { Errors } from "src/lib/Errors.sol";
import { IOracleAdapter } from "src/interfaces/IOracleAdapter.sol";

import { ICOSaleTest } from "test/ICOSaleTest.sol";

contract OracleAdapterSetManualPriceTest is ICOSaleTest {
    address internal token = makeAddr("token");

    function setUp() public {
        fixture();
    }

    function test_whenOwnerSetsValidTokenAndPriceAfterInterval_success() external {
        uint256 interval = oracle.manualUpdateInterval();
        vm.warp(interval);

        uint256 price = 3500 * 1 ether;
        uint256 ts = block.timestamp;

        vm.prank(deployer);
        vm.expectEmit(true, true, true, true);
        emit IOracleAdapter.ManualPriceUpdated(token, price, ts);
        oracle.setManualPrice(token, price);

        assertEq(oracle.manualPrices(token), price);
        assertEq(oracle.getPriceInUSD(token), price);
        assertEq(oracle.manualLastUpdated(token), ts);
    }

    function test_whenOwnerUpdatesExistingAfterInterval_overwrites() external {
        uint256 interval = oracle.manualUpdateInterval();
        vm.warp(interval);

        uint256 oldPrice = 2 ether;
        vm.prank(deployer);
        oracle.setManualPrice(token, oldPrice);

        uint256 firstUpdated = oracle.manualLastUpdated(token);
        assertEq(oracle.manualPrices(token), oldPrice);
        assertEq(oracle.getPriceInUSD(token), oldPrice);

        vm.warp(firstUpdated + interval);
        uint256 newPrice = 3 ether;

        vm.prank(deployer);
        vm.expectEmit(true, true, true, true);
        emit IOracleAdapter.ManualPriceUpdated(token, newPrice, block.timestamp);
        oracle.setManualPrice(token, newPrice);

        assertEq(oracle.manualPrices(token), newPrice);
        assertEq(oracle.getPriceInUSD(token), newPrice);
        assertEq(oracle.manualLastUpdated(token), block.timestamp);
        assertGt(oracle.manualLastUpdated(token), firstUpdated);
    }

    function test_whenCalledBeforeInterval_revert() external {
        uint256 interval = oracle.manualUpdateInterval();
        vm.warp(interval);

        uint256 initialPrice = 10 ether;
        vm.prank(deployer);
        oracle.setManualPrice(token, initialPrice);

        uint256 prevUpdated = oracle.manualLastUpdated(token);

        vm.warp(prevUpdated + interval - 1);

        vm.prank(deployer);
        vm.expectRevert(Errors.EarlyManualUpdate.selector);
        oracle.setManualPrice(token, 11 ether);

        assertEq(oracle.manualPrices(token), initialPrice);
        assertEq(oracle.manualLastUpdated(token), prevUpdated);
    }

    function test_whenTokenIsZeroAddress_revert() external {
        vm.prank(deployer);
        vm.expectRevert(Errors.ZeroAddress.selector);
        oracle.setManualPrice(address(0), 1 ether);
    }

    function test_whenPriceIsZero_revert() external {
        vm.prank(deployer);
        vm.expectRevert(Errors.ZeroAmount.selector);
        oracle.setManualPrice(token, 0);
    }

    function test_whenCalledByNonOwner_revertUnauthorized() external {
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, bob));
        oracle.setManualPrice(token, 1 ether);

        assertEq(oracle.manualPrices(token), 0);
        assertEq(oracle.manualLastUpdated(token), 0);
    }
}
