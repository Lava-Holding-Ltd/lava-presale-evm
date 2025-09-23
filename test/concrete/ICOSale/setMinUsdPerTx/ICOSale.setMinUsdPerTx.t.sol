// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { INITIAL_ADMIN } from "script/lib/DataStore.sol";
import { Errors } from "src/lib/Errors.sol";
import { IICOSale } from "src/interfaces/IICOSale.sol";

import { ICOSaleTest } from "test/ICOSaleTest.sol";

contract ICOSaleSetMinUsdPerTxTest is ICOSaleTest {
    function setUp() public {
        fixture();
    }

    function test_whenOwnerSetsNonZeroValue_success() external {
        uint256 newMin = 100 * 1 ether;

        assertEq(tokenSale.minUsdPerTx(), 0);

        vm.prank(INITIAL_ADMIN);
        vm.expectEmit(true, true, true, true);
        emit IICOSale.MinUsdPerTxUpdated(newMin, INITIAL_ADMIN);
        tokenSale.setMinUsdPerTx(newMin);

        assertEq(tokenSale.minUsdPerTx(), newMin);
    }

    function test_whenOwnerOverwritesPreviousValue_success() external {
        uint256 oldMin = 50 * 1 ether;
        uint256 newMin = 75 * 1 ether;

        assertEq(tokenSale.minUsdPerTx(), 0);

        vm.prank(INITIAL_ADMIN);
        tokenSale.setMinUsdPerTx(oldMin);
        assertEq(tokenSale.minUsdPerTx(), oldMin);

        vm.prank(INITIAL_ADMIN);
        vm.expectEmit(true, true, true, true);
        emit IICOSale.MinUsdPerTxUpdated(newMin, INITIAL_ADMIN);
        tokenSale.setMinUsdPerTx(newMin);

        assertEq(tokenSale.minUsdPerTx(), newMin);
    }

    function test_whenZeroValue_revert() external {
        vm.prank(INITIAL_ADMIN);
        vm.expectRevert(Errors.ZeroAmount.selector);
        tokenSale.setMinUsdPerTx(0);
    }

    function test_whenCalledByNonOwner_revert() external {
        uint256 preset = 25 * 1 ether;
        vm.prank(INITIAL_ADMIN);
        tokenSale.setMinUsdPerTx(preset);

        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, bob));
        tokenSale.setMinUsdPerTx(99 * 1 ether);

        assertEq(tokenSale.minUsdPerTx(), preset);
    }
}
