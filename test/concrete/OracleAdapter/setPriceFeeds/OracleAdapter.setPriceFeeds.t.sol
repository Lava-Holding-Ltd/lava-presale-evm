// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { INITIAL_ADMIN } from "script/lib/DataStore.sol";
import { Errors } from "src/lib/Errors.sol";
import { IOracleAdapter } from "src/interfaces/IOracleAdapter.sol";

import { ICOSaleTest } from "test/ICOSaleTest.sol";

contract OracleAdapterSetPriceFeedsTest is ICOSaleTest {
    address internal tokenA = makeAddr("tokenA");
    address internal tokenB = makeAddr("tokenB");
    address internal feedA = makeAddr("feedA");
    address internal feedB = makeAddr("feedB");

    function setUp() public {
        fixture();
    }

    function test_whenOwnerSetsValidArrays_success() external {
        address[] memory tokens = new address[](2);
        address[] memory feeds = new address[](2);
        uint256[] memory heartbeats = new uint256[](2);

        tokens[0] = tokenA; 
        tokens[1] = tokenB;
        
        feeds[0] = feedA;
        feeds[1] = feedB;
        
        heartbeats[0] = 1 hours; 
        heartbeats[1] = 2 hours;

        vm.prank(INITIAL_ADMIN);
        vm.expectEmit(true, true, true, true);
        emit IOracleAdapter.PriceFeedSet(tokens, feeds, heartbeats);
        oracle.setPriceFeeds(tokens, feeds, heartbeats);

        assertEq(oracle.priceFeeds(tokenA), feedA);
        assertEq(oracle.priceFeeds(tokenB), feedB);
        assertEq(oracle.heartbeats(tokenA), 1 hours);
        assertEq(oracle.heartbeats(tokenB), 2 hours);
    }

    function test_whenUpdatingExistingEntries_overwrites() external {
        address[] memory tokens = new address[](1);
        address[] memory feeds = new address[](1);
        uint256[] memory heartbeats = new uint256[](1);

        tokens[0] = tokenA;
        feeds[0] = feedA;
        heartbeats[0] = 30 minutes;

        vm.prank(INITIAL_ADMIN);
        oracle.setPriceFeeds(tokens, feeds, heartbeats);

        assertEq(oracle.priceFeeds(tokenA), feedA);
        assertEq(oracle.heartbeats(tokenA), 30 minutes);

        address[] memory tokens2 = new address[](1);
        address[] memory feeds2 = new address[](1);
        uint256[] memory heartbeats2 = new uint256[](1);

        tokens2[0] = tokenA;
        feeds2[0] = feedB;
        heartbeats2[0] = 45 minutes;

        vm.prank(INITIAL_ADMIN);
        vm.expectEmit(true, true, true, true);
        emit IOracleAdapter.PriceFeedSet(tokens2, feeds2, heartbeats2);
        oracle.setPriceFeeds(tokens2, feeds2, heartbeats2);

        assertEq(oracle.priceFeeds(tokenA), feedB);
        assertEq(oracle.heartbeats(tokenA), 45 minutes);
    }

    function test_whenArraysHaveDifferentLengths_revert() external {
        address[] memory tokens = new address[](2);
        address[] memory feeds = new address[](1);
        uint256[] memory heartbeats = new uint256[](2);

        tokens[0] = tokenA; 
        tokens[1] = tokenB;
        
        feeds[0] = feedA;
        
        heartbeats[0] = 1 hours;
        heartbeats[1] = 2 hours;

        vm.prank(INITIAL_ADMIN);
        vm.expectRevert(Errors.LengthMismatch.selector);
        oracle.setPriceFeeds(tokens, feeds, heartbeats);
    }

    function test_whenZeroTokenAddress_revert() external {
        assertEq(oracle.priceFeeds(tokenA), address(0));
        assertEq(oracle.heartbeats(tokenA), 0);

        address[] memory tokens = new address[](1);
        address[] memory feeds = new address[](1);
        uint256[] memory heartbeats = new uint256[](1);

        tokens[0] = address(0);
        feeds[0] = feedA;
        heartbeats[0] = 1 hours;

        vm.prank(INITIAL_ADMIN);
        vm.expectRevert(Errors.ZeroAddress.selector);
        oracle.setPriceFeeds(tokens, feeds, heartbeats);

        assertEq(oracle.priceFeeds(tokenA), address(0));
        assertEq(oracle.heartbeats(tokenA), 0);
    }

    function test_whenZeroFeedAddress_revert() external {
        assertEq(oracle.priceFeeds(tokenA), address(0));
        assertEq(oracle.heartbeats(tokenA), 0);

        address[] memory tokens = new address[](1);
        address[] memory feeds = new address[](1);
        uint256[] memory heartbeats = new uint256[](1);

        tokens[0] = tokenA;
        feeds[0] = address(0);
        heartbeats[0] = 1 hours;

        vm.prank(INITIAL_ADMIN);
        vm.expectRevert(Errors.ZeroAddress.selector);
        oracle.setPriceFeeds(tokens, feeds, heartbeats);

        assertEq(oracle.priceFeeds(tokenA), address(0));
        assertEq(oracle.heartbeats(tokenA), 0);
    }

    function test_whenZeroHeartbeat_revert() external {
        assertEq(oracle.priceFeeds(tokenA), address(0));
        assertEq(oracle.heartbeats(tokenA), 0);

        address[] memory tokens = new address[](1);
        address[] memory feeds = new address[](1);
        uint256[] memory heartbeats = new uint256[](1);

        tokens[0] = tokenA;
        feeds[0] = feedA;
        heartbeats[0] = 0;

        vm.prank(INITIAL_ADMIN);
        vm.expectRevert(Errors.ZeroAmount.selector);
        oracle.setPriceFeeds(tokens, feeds, heartbeats);

        assertEq(oracle.priceFeeds(tokenA), address(0));
        assertEq(oracle.heartbeats(tokenA), 0);
    }

    function test_whenCalledByNonOwner_revert() external {
        address[] memory tokens = new address[](1);
        address[] memory feeds = new address[](1);
        uint256[] memory heartbeats = new uint256[](1);

        tokens[0] = tokenA;
        feeds[0] = feedA;
        heartbeats[0] = 1 hours;

        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, bob));
        oracle.setPriceFeeds(tokens, feeds, heartbeats);

        assertEq(oracle.priceFeeds(tokenA), address(0));
        assertEq(oracle.heartbeats(tokenA), 0);
    }
}
