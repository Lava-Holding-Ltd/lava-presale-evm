// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Errors } from "src/lib/Errors.sol";
import { Constants } from "src/lib/Constants.sol";
import { AggregatorV3Interface } from "@chainlink-contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import { INITIAL_ADMIN } from "script/lib/DataStore.sol";

import { ICOSaleTest } from "test/ICOSaleTest.sol";

contract OracleAdapterGetPriceInUSDTest is ICOSaleTest {
    address internal manualToken = makeAddr("manualToken");

    function setUp() public {
        fixture();
    }

    function test_whenTokenIsUSDCorUSDT_success() external view {
        assertEq(oracle.getPriceInUSD(Constants.USDC), 1 ether);
        assertEq(oracle.getPriceInUSD(Constants.USDT), 1 ether);
    }

    function test_whenFeedFresh_scalesByDecimalsAndMatchesChainlink_success() external {
        address feedAddr = oracle.priceFeeds(Constants.WETH);
        uint256 hb = oracle.heartbeats(Constants.WETH);
        assertTrue(feedAddr != address(0));
        assertTrue(hb > 0);

        AggregatorV3Interface feed = AggregatorV3Interface(feedAddr);
        (, int256 answer,, uint256 updatedAt,) = feed.latestRoundData();
        uint8 feedDec = feed.decimals();

        assertGt(answer, 0);
        if (block.timestamp > updatedAt + hb) {
            vm.warp(updatedAt + hb);
        }

        uint256 expected;
        if (feedDec == 18) expected = uint256(answer);
        else if (feedDec < 18) expected = uint256(answer) * (10 ** (18 - feedDec));
        else expected = uint256(answer) / (10 ** (feedDec - 18));

        assertEq(oracle.getPriceInUSD(Constants.WETH), expected);
    }

    function test_whenFeedFreshnessOnBoundary_success() external {
        AggregatorV3Interface feed = AggregatorV3Interface(oracle.priceFeeds(Constants.WETH));
        (, int256 answer,, uint256 updatedAt,) = feed.latestRoundData();
        uint8 feedDec = feed.decimals();

        vm.warp(updatedAt + oracle.heartbeats(Constants.WETH));

        uint256 expected;
        if (feedDec == 18) expected = uint256(answer);
        else if (feedDec < 18) expected = uint256(answer) * (10 ** (18 - feedDec));
        else expected = uint256(answer) / (10 ** (feedDec - 18));

        assertEq(oracle.getPriceInUSD(Constants.WETH), expected);
    }

    function test_whenFeedStale_revert() external {
        address feedAddr = oracle.priceFeeds(Constants.WETH);
        uint256 hb = oracle.heartbeats(Constants.WETH);
        AggregatorV3Interface feed = AggregatorV3Interface(feedAddr);
        (,,, uint256 updatedAt,) = feed.latestRoundData();

        vm.warp(updatedAt + hb + 1);

        vm.expectRevert(Errors.StalePriceFeed.selector);
        oracle.getPriceInUSD(Constants.WETH);
    }

    function test_whenManualFreshnessOnBoundary_success() external {
        assertEq(oracle.priceFeeds(manualToken), address(0));

        uint256 interval = oracle.manualUpdateInterval();
        vm.warp(interval);

        uint256 manualPrice = 123 * 1 ether;
        vm.prank(INITIAL_ADMIN);
        oracle.setManualPrice(manualToken, manualPrice);

        vm.warp(oracle.manualLastUpdated(manualToken) + interval);

        assertEq(oracle.getPriceInUSD(manualToken), manualPrice);
    }

    function test_whenManualNotSet_revert() external {
        assertEq(oracle.priceFeeds(manualToken), address(0));
        vm.expectRevert(Errors.ZeroAmount.selector);
        oracle.getPriceInUSD(manualToken);
    }

    function test_whenManualStale_revert() external {
        uint256 interval = oracle.manualUpdateInterval();
        vm.warp(interval);

        vm.prank(INITIAL_ADMIN);
        oracle.setManualPrice(manualToken, 42 * 1 ether);

        vm.warp(oracle.manualLastUpdated(manualToken) + interval + 1);

        vm.expectRevert(Errors.StaleManualPrice.selector);
        oracle.getPriceInUSD(manualToken);
    }
}
