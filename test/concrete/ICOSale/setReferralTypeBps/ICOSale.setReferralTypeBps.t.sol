// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { Errors } from "src/lib/Errors.sol";
import { IICOSale } from "src/interfaces/IICOSale.sol";

import { ICOSaleTest } from "test/ICOSaleTest.sol";

contract ICOSaleSetReferralTypeBpsTest is ICOSaleTest {
    // RefType enum: 0 = NoReferral, 1 = Influencer, 2 = Media
    uint8 internal constant NO = 0;
    uint8 internal constant INF = 1;
    uint8 internal constant MED = 2;

    function setUp() public {
        fixture();
    }

    function test_whenOwnerSetsInfluencerWithinBounds_success() external {
        uint16 pct = 760;

        assertEq(tokenSale.referralBonusBpsByType(INF), 0);

        vm.prank(deployer);
        vm.expectEmit(true, true, true, true);
        emit IICOSale.ReferralTypePercentageUpdated(INF, pct, deployer);
        tokenSale.setReferralTypeBps(INF, pct);

        assertEq(tokenSale.referralBonusBpsByType(INF), pct);
    }

    function test_whenOwnerSetsMediaWithinBounds_success() external {
        uint16 pct = 500;

        assertEq(tokenSale.referralBonusBpsByType(MED), 0);

        vm.prank(deployer);
        vm.expectEmit(true, true, true, true);
        emit IICOSale.ReferralTypePercentageUpdated(MED, pct, deployer);
        tokenSale.setReferralTypeBps(MED, pct);

        assertEq(tokenSale.referralBonusBpsByType(MED), pct);
    }

    function test_whenOverwritingExistingValue_success() external {
        uint16 initialPct = 300;
        uint16 newPct = 1000;

        vm.prank(deployer);
        tokenSale.setReferralTypeBps(INF, initialPct);
        assertEq(tokenSale.referralBonusBpsByType(INF), initialPct);

        vm.prank(deployer);
        vm.expectEmit(true, true, true, true);
        emit IICOSale.ReferralTypePercentageUpdated(INF, newPct, deployer);
        tokenSale.setReferralTypeBps(INF, newPct);

        assertEq(tokenSale.referralBonusBpsByType(INF), newPct);
    }

    function test_whenZeroPercentage_success() external {
        vm.prank(deployer);
        tokenSale.setReferralTypeBps(INF, 0);
        assertEq(tokenSale.referralBonusBpsByType(INF), 0);
    }

    function test_whenInvalidRefType_revert() external {
        uint16 initialPct = 1000;

        vm.prank(deployer);
        tokenSale.setReferralTypeBps(INF, initialPct);
        assertEq(tokenSale.referralBonusBpsByType(INF), initialPct);

        vm.prank(deployer);
        vm.expectRevert(Errors.InvalidReferralType.selector);
        tokenSale.setReferralTypeBps(NO, 500);

        vm.prank(deployer);
        vm.expectRevert(Errors.InvalidReferralType.selector);
        tokenSale.setReferralTypeBps(3, 500);

        assertEq(tokenSale.referralBonusBpsByType(INF), initialPct);
    }

    function test_whenPercentageAboveDivisor_revert() external {
        uint16 initialPct = 200;

        vm.prank(deployer);
        tokenSale.setReferralTypeBps(MED, initialPct);
        assertEq(tokenSale.referralBonusBpsByType(MED), initialPct);

        uint16 invalidPct = 1001;
        vm.prank(deployer);
        vm.expectRevert(Errors.InvalidReferralPercentage.selector);
        tokenSale.setReferralTypeBps(MED, invalidPct);

        assertEq(tokenSale.referralBonusBpsByType(MED), initialPct);
    }

    function test_whenCalledByNonOwner_revert() external {
        uint16 initialPct = 700;

        vm.prank(deployer);
        tokenSale.setReferralTypeBps(INF, initialPct);
        assertEq(tokenSale.referralBonusBpsByType(INF), initialPct);

        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, bob));
        tokenSale.setReferralTypeBps(INF, 900);

        assertEq(tokenSale.referralBonusBpsByType(INF), initialPct);
    }
}
