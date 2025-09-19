// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Script, console } from "forge-std/Script.sol";

import { ICOSale } from "src/ICOSale.sol";
import { INITIAL_ADMIN, PLATFORM_TREASURY_WALLET } from "script/lib/DataStore.sol";

contract DeployICOSaleScript is Script {
    address internal oracle;

    function run() external {
        vm.startBroadcast();

        address icoSale = address(new ICOSale(INITIAL_ADMIN, oracle, PLATFORM_TREASURY_WALLET, 330_000_000 * 1 ether));
        console.log("The ICOSale SC deployed at:", icoSale);

        vm.stopBroadcast();
    }
}

