// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { Errors } from "src/lib/Errors.sol";
import { Constants } from "src/lib/Constants.sol";
import { IICOSale } from "src/interfaces/IICOSale.sol";

import { ICOSaleTest } from "test/ICOSaleTest.sol";

contract ICOSaleFinalizeSaleTest is ICOSaleTest {
    function setUp() public {
        fixture();
    }

    function test_whenOwnerFinalizes_afterAllRounds_success() external {
        assertFalse(tokenSale.saleFinalized());

        _createRounds(Constants.MAX_ROUNDS);

        vm.prank(deployer);
        vm.expectEmit(true, true, true, true);
        emit IICOSale.SaleFinalized(0, deployer);
        tokenSale.finalizeSale();

        assertTrue(tokenSale.saleFinalized());
    }

    function test_whenOwnerFinalizes_beforeAllRounds_revert() external {
        _createRounds(Constants.MAX_ROUNDS - 1);

        vm.prank(deployer);
        vm.expectRevert(Errors.OngoingSaleRounds.selector);
        tokenSale.finalizeSale();
    }

    function test_whenOwnerFinalizesTwice_revert() external {
        _createRounds(Constants.MAX_ROUNDS);

        vm.prank(deployer);
        tokenSale.finalizeSale();
        assertTrue(tokenSale.saleFinalized());

        vm.prank(deployer);
        vm.expectRevert(Errors.SaleAlreadyFinalized.selector);
        tokenSale.finalizeSale();
    }

    function test_whenNonOwnerCalls_revert() external {
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, bob));
        tokenSale.finalizeSale();
    }

    function _createRounds(uint256 n) internal {
        uint256 nowTs = block.timestamp;
        for (uint256 i; i < n; i++) {
            uint256 startTime = nowTs + (i + 1) * 1000;
            uint256 endTime = startTime + 100;
            uint256 tokenPrice = 1 ether;
            uint256 capTotal = 1e24;

            vm.prank(deployer);
            tokenSale.setNewRound(startTime, endTime, tokenPrice, capTotal);
        }
    }
}
