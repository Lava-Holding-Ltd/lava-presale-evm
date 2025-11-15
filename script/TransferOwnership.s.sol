// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Script, console } from "forge-std/Script.sol";

import { ICOSale } from "src/ICOSale.sol";
import { OracleAdapter } from "src/OracleAdapter.sol";

contract TransferOwnershipScript is Script {
    /// @dev The address of the ICOSale contract
    address internal icoSaleAddress;
    /// @dev The address of the OracleAdapter contract
    address internal oracleAdapterAddress;
    /// @dev The new owner address
    address internal newOwner;

    function run() external {
        newOwner = vm.envAddress("NEW_OWNER");
        require(newOwner != address(0), "NEW_OWNER is zero");

        vm.startBroadcast();

        try vm.envAddress("ICOSALE") returns (address addr) {
            if (addr != address(0)) {
                icoSaleAddress = addr;
                ICOSale icoSaleContract = ICOSale(payable(icoSaleAddress));
                address currentOwner = icoSaleContract.owner();
                console.log("Current ICOSale owner:", currentOwner);
                console.log("Transferring ICOSale ownership to:", newOwner);

                icoSaleContract.transferOwnership(newOwner);

                console.log("ICOSale ownership transferred successfully");
            }
        } catch {
            console.log("ICOSALE not provided, skipping ICOSale ownership transfer");
        }

        // Transfer OracleAdapter ownership if address is provided
        try vm.envAddress("ORACLE") returns (address addr) {
            if (addr != address(0)) {
                oracleAdapterAddress = addr;
                OracleAdapter oracleAdapterContract = OracleAdapter(oracleAdapterAddress);
                address currentOwner = oracleAdapterContract.owner();
                console.log("Current OracleAdapter owner:", currentOwner);
                console.log("Transferring OracleAdapter ownership to:", newOwner);

                oracleAdapterContract.transferOwnership(newOwner);

                console.log("OracleAdapter ownership transferred successfully");
            }
        } catch {
            console.log("ORACLE not provided, skipping OracleAdapter ownership transfer");
        }

        vm.stopBroadcast();
    }
}
