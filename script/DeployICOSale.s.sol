// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Script, console } from "forge-std/Script.sol";

import { ICOSale } from "src/ICOSale.sol";

contract DeployICOSaleScript is Script {
    /// @dev The address of the OracleAdapter SC
    address internal oracle;
    /// @dev The address of the initial admin
    address internal initialAdmin;
    /// @dev The address of the platform treasury wallet to receive all funds
    address internal platformTreasury;
    /// @dev The total allocation of tokens for the ICO sale
    uint256 internal totalAllocation;

    function run() external {
        vm.startBroadcast();

        address icoSale = address(new ICOSale(initialAdmin, oracle, platformTreasury, totalAllocation));
        console.log("The ICOSale SC deployed at:", icoSale);

        vm.stopBroadcast();
    }
}
