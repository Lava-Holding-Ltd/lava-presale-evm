// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { INITIAL_ADMIN } from "script/lib/DataStore.sol";
import { Errors } from "src/lib/Errors.sol";
import { IICOSale } from "src/interfaces/IICOSale.sol";

import { ICOSaleTest } from "test/ICOSaleTest.sol";

contract ICOSaleFinalizeSaleTest is ICOSaleTest {
    function setUp() public {
        fixture();
    }

    function test_whenOwnerFinalizes_success() external {
        assertFalse(tokenSale.saleFinalized());

        vm.prank(INITIAL_ADMIN);
        vm.expectEmit(true, true, true, true);
        emit IICOSale.SaleFinalized(0, INITIAL_ADMIN);
        tokenSale.finalizeSale();

        assertTrue(tokenSale.saleFinalized());
    }

    function test_whenOwnerFinalizesTwice_revert() external {
        vm.prank(INITIAL_ADMIN);
        tokenSale.finalizeSale();
        assertTrue(tokenSale.saleFinalized());

        vm.prank(INITIAL_ADMIN);
        vm.expectRevert(Errors.SaleAlreadyFinalized.selector);
        tokenSale.finalizeSale();
    }

    function test_whenNonOwnerCalls_revert() external {
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, bob));
        tokenSale.finalizeSale();
    }
}
