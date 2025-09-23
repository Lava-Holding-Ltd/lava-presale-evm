// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Test } from "./Test.sol";

import {
    INITIAL_ADMIN,
    PLATFORM_TREASURY_WALLET,
    ETHEREUM_WETH_USD_CHAINLINK,
    ETHEREUM_WETH_USD_HEARTBEAT
} from "script/lib/DataStore.sol";

import { ICOSale } from "src/ICOSale.sol";
import { OracleAdapter } from "src/OracleAdapter.sol";
import { Constants } from "src/lib/Constants.sol";

contract ICOSaleTest is Test {
    uint256 internal constant depositAmount = 100e6;

    ICOSale internal tokenSale;
    OracleAdapter internal oracle;

    function fixture() internal {
        vm.createSelectFork("https://ethereum-rpc.publicnode.com");

        oracle = new OracleAdapter(INITIAL_ADMIN);
        tokenSale = new ICOSale(INITIAL_ADMIN, address(oracle), PLATFORM_TREASURY_WALLET, 330 * 1e6 * 1 ether);

        address[] memory tokens = new address[](1);
        tokens[0] = Constants.WETH;

        address[] memory feeds = new address[](1);
        feeds[0] = ETHEREUM_WETH_USD_CHAINLINK;

        uint256[] memory heartbeats = new uint256[](1);
        heartbeats[0] = ETHEREUM_WETH_USD_HEARTBEAT;

        vm.prank(INITIAL_ADMIN);
        oracle.setPriceFeeds(tokens, feeds, heartbeats);

        vm.deal(alice, 10 ether);
        deal(Constants.USDT, alice, depositAmount);
        deal(Constants.USDC, alice, depositAmount);
    }
}
