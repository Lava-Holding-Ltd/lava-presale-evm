// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Script, console } from "forge-std/Script.sol";

import { OracleAdapter } from "src/OracleAdapter.sol";
import { Constants } from "src/lib/Constants.sol";
import { ETHEREUM_WETH_USD_CHAINLINK, ETHEREUM_WETH_USD_HEARTBEAT } from "script/lib/DataStore.sol";

contract DeployOracleAdapterScript is Script {
    /// @dev The initial admin address who has the rights to manage the OracleAdapter contract
    address internal initialAdmin;

    function run() external {
        address[] memory tokens = new address[](1);
        tokens[0] = Constants.WETH;

        address[] memory feeds = new address[](1);
        feeds[0] = ETHEREUM_WETH_USD_CHAINLINK;

        uint256[] memory heartbeats = new uint256[](1);
        heartbeats[0] = ETHEREUM_WETH_USD_HEARTBEAT;

        vm.startBroadcast();

        OracleAdapter oracleAdapter = new OracleAdapter(initialAdmin);
        console.log("The OracleAdapter SC deployed to:", address(oracleAdapter));

        oracleAdapter.setPriceFeeds(tokens, feeds, heartbeats);
        console.log("The OracleAdapter price feed set");

        vm.stopBroadcast();
    }
}
