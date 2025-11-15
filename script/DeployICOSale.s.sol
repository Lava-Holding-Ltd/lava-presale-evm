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
        // REQUIRED env vars
        //   INITIAL_ADMIN (address)
        //   ORACLE (address)
        //   PLATFORM_TREASURY (address)
        //   TOTAL_ALLOCATION (uint256)
        initialAdmin = vm.envAddress("INITIAL_ADMIN");
        oracle = vm.envAddress("ORACLE");
        platformTreasury = vm.envAddress("PLATFORM_TREASURY");
        totalAllocation = vm.envUint("TOTAL_ALLOCATION");

        require(initialAdmin != address(0), "INITIAL_ADMIN is zero");
        require(oracle != address(0), "ORACLE is zero");
        require(platformTreasury != address(0), "PLATFORM_TREASURY is zero");
        require(totalAllocation > 0, "TOTAL_ALLOCATION is zero");

        vm.startBroadcast();

        address icoSale = address(new ICOSale(initialAdmin, oracle, platformTreasury, totalAllocation));
        console.log("The ICOSale SC deployed at:", icoSale);

        vm.stopBroadcast();
    }
}
