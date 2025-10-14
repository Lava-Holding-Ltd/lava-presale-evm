// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { Errors } from "src/lib/Errors.sol";
import { Constants } from "src/lib/Constants.sol";
import { IICOSale } from "src/interfaces/IICOSale.sol";

import { ICOSaleTest } from "test/ICOSaleTest.sol";

contract ICOSaleSetApprovedAssetTest is ICOSaleTest {
    address internal newToken = makeAddr("newToken");

    function setUp() public {
        fixture();
    }

    function test_whenOwnerFlipsFromFalseToTrue_success() external {
        assertFalse(tokenSale.isApprovedAsset(newToken));

        vm.prank(deployer);
        vm.expectEmit(true, true, true, true);
        emit IICOSale.PayAssetApprovalSet(newToken, true, deployer);
        tokenSale.setApprovedAsset(newToken, true);

        assertTrue(tokenSale.isApprovedAsset(newToken));
    }

    function test_whenOwnerFlipsFromTrueToFalse_success() external {
        assertTrue(tokenSale.isApprovedAsset(Constants.USDC));

        vm.prank(deployer);
        vm.expectEmit(true, true, true, true);
        emit IICOSale.PayAssetApprovalSet(Constants.USDC, false, deployer);
        tokenSale.setApprovedAsset(Constants.USDC, false);

        assertFalse(tokenSale.isApprovedAsset(Constants.USDC));
    }

    function test_whenZeroAsset_revert() external {
        bool beforeUSDT = tokenSale.isApprovedAsset(Constants.USDT);

        vm.prank(deployer);
        vm.expectRevert(Errors.ZeroAddress.selector);
        tokenSale.setApprovedAsset(address(0), true);

        assertEq(tokenSale.isApprovedAsset(Constants.USDT), beforeUSDT);
    }

    function test_whenIndicatorAlreadyTrue_revert() external {
        assertTrue(tokenSale.isApprovedAsset(Constants.WETH));

        vm.prank(deployer);
        vm.expectRevert(Errors.IndicatorAlreadySet.selector);
        tokenSale.setApprovedAsset(Constants.WETH, true);
    }

    function test_whenIndicatorAlreadyFalse_revert() external {
        assertFalse(tokenSale.isApprovedAsset(newToken));

        vm.prank(deployer);
        vm.expectRevert(Errors.IndicatorAlreadySet.selector);
        tokenSale.setApprovedAsset(newToken, false);
    }

    function test_whenCalledByNonOwner_revert() external {
        assertFalse(tokenSale.isApprovedAsset(newToken));

        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, bob));
        tokenSale.setApprovedAsset(newToken, true);

        assertFalse(tokenSale.isApprovedAsset(newToken));
    }
}
