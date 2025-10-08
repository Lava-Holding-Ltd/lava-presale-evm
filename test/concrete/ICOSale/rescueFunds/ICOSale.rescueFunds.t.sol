// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { INITIAL_ADMIN, PLATFORM_TREASURY_WALLET } from "script/lib/DataStore.sol";
import { Errors } from "src/lib/Errors.sol";
import { Constants } from "src/lib/Constants.sol";
import { IICOSale } from "src/interfaces/IICOSale.sol";

import { ICOSaleTest } from "test/ICOSaleTest.sol";

contract ICOSaleRescueFundsTest is ICOSaleTest {
    function setUp() public {
        fixture();
    }

    function test_whenOwnerRescuesERC20_success() external {
        deal(Constants.USDC, address(tokenSale), depositAmount);

        uint256 treasuryBefore = IERC20(Constants.USDC).balanceOf(PLATFORM_TREASURY_WALLET);
        uint256 saleBefore = IERC20(Constants.USDC).balanceOf(address(tokenSale));

        vm.prank(INITIAL_ADMIN);
        vm.expectEmit(true, true, true, true);
        emit IICOSale.FundsRescued(Constants.USDC, PLATFORM_TREASURY_WALLET, depositAmount, INITIAL_ADMIN);
        tokenSale.rescueFunds(Constants.USDC, depositAmount);

        assertEq(IERC20(Constants.USDC).balanceOf(PLATFORM_TREASURY_WALLET), treasuryBefore + depositAmount);
        assertEq(IERC20(Constants.USDC).balanceOf(address(tokenSale)), saleBefore - depositAmount);
    }

    function test_whenOwnerRescuesERC20_insufficientBalance_revert() external {
        uint256 treasuryBefore = IERC20(Constants.USDC).balanceOf(PLATFORM_TREASURY_WALLET);
        uint256 saleBefore = IERC20(Constants.USDC).balanceOf(address(tokenSale));

        vm.prank(INITIAL_ADMIN);
        vm.expectRevert();
        tokenSale.rescueFunds(Constants.USDC, 1);

        assertEq(IERC20(Constants.USDC).balanceOf(PLATFORM_TREASURY_WALLET), treasuryBefore);
        assertEq(IERC20(Constants.USDC).balanceOf(address(tokenSale)), saleBefore);
    }

    function test_whenOwnerRescuesNativeETH_success() external {
        uint256 amount = 0.27 ether;

        vm.deal(address(tokenSale), amount);

        uint256 treasuryBefore = PLATFORM_TREASURY_WALLET.balance;
        uint256 saleBefore = address(tokenSale).balance;

        vm.prank(INITIAL_ADMIN);
        vm.expectEmit(true, true, true, true);
        emit IICOSale.FundsRescued(address(0), PLATFORM_TREASURY_WALLET, amount, INITIAL_ADMIN);
        tokenSale.rescueFunds(address(0), amount);

        assertEq(PLATFORM_TREASURY_WALLET.balance, treasuryBefore + amount);
        assertEq(address(tokenSale).balance, saleBefore - amount);
    }

    function test_whenOwnerRescuesNativeETH_insufficientBalance_revert() external {
        vm.prank(INITIAL_ADMIN);
        vm.expectRevert(Errors.InsufficientBalance.selector);
        tokenSale.rescueFunds(address(0), address(tokenSale).balance + 1 wei);
    }

    function test_whenAmountIsZero_revert() external {
        vm.prank(INITIAL_ADMIN);
        vm.expectRevert(Errors.ZeroAmount.selector);
        tokenSale.rescueFunds(Constants.USDC, 0);
    }

    function test_whenCalledByNonOwner_revert() external {
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, bob));
        tokenSale.rescueFunds(Constants.USDC, 1);
    }
}
