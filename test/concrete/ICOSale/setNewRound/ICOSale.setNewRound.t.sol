// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { Errors } from "src/lib/Errors.sol";
import { Constants } from "src/lib/Constants.sol";
import { IICOSale } from "src/interfaces/IICOSale.sol";

import { ICOSaleTest } from "test/ICOSaleTest.sol";

contract ICOSaleSetNewRoundTest is ICOSaleTest {
    function setUp() public {
        fixture();
        vm.warp(1_000_000);
    }

    function test_whenFirstRoundValid_success() external {
        (uint256 s, uint256 e, uint256 p, uint256 c) = _params(10, 1 days, 0.2 ether, 1_000_000 ether);

        (uint256 _s, uint256 _e, uint256 _p, uint256 _c, uint256 _sold, bool _active) = tokenSale.rounds(0);
        assertEq(_s, 0);
        assertEq(tokenSale.currentRoundId(), 0);

        vm.prank(deployer);
        vm.expectEmit(true, true, true, true);
        emit IICOSale.NewRoundSet(0, s, e, p, c);
        tokenSale.setNewRound(s, e, p, c);

        assertEq(tokenSale.currentRoundId(), 0);
        (_s, _e, _p, _c, _sold, _active) = tokenSale.rounds(0);
        assertEq(_s, s);
        assertEq(_e, e);
        assertEq(_p, p);
        assertEq(_c, c);
        assertEq(_sold, 0);
        assertTrue(_active);
    }

    function test_whenPriorActiveRound_newRoundDeactivatesPreviousAndIncrementsId_success() external {
        (uint256 s0, uint256 e0, uint256 p0, uint256 c0) = _params(10, 2 days, 0.3 ether, 2_000_000 ether);

        vm.prank(deployer);
        tokenSale.setNewRound(s0, e0, p0, c0);
        assertEq(tokenSale.currentRoundId(), 0);
        (,,,,, bool active0Before) = tokenSale.rounds(0);
        assertTrue(active0Before);

        (uint256 s1, uint256 e1, uint256 p1, uint256 c1) = _params(20, 3 days, 0.5 ether, 3_000_000 ether);
        vm.prank(deployer);
        vm.expectEmit(true, true, true, true);
        emit IICOSale.NewRoundSet(1, s1, e1, p1, c1);
        tokenSale.setNewRound(s1, e1, p1, c1);

        assertEq(tokenSale.currentRoundId(), 1);
        (,,,,, bool active0After) = tokenSale.rounds(0);
        assertFalse(active0After);

        (uint256 _s1, uint256 _e1, uint256 _p1, uint256 _c1, uint256 sold1, bool active1) = tokenSale.rounds(1);
        assertEq(_s1, s1);
        assertEq(_e1, e1);
        assertEq(_p1, p1);
        assertEq(_c1, c1);
        assertEq(sold1, 0);
        assertTrue(active1);
    }

    function test_whenStartIsZero_revert() external {
        (, uint256 e, uint256 p, uint256 c) = _params(10, 1 days, 0.1 ether, 1_000_000 ether);

        vm.prank(deployer);
        vm.expectRevert(Errors.InvalidTimeframe.selector);
        tokenSale.setNewRound(0, e, p, c);
    }

    function test_whenEndIsZero_revert() external {
        (uint256 s,, uint256 p, uint256 c) = _params(10, 1 days, 0.1 ether, 1_000_000 ether);

        vm.prank(deployer);
        vm.expectRevert(Errors.InvalidTimeframe.selector);
        tokenSale.setNewRound(s, 0, p, c);
    }

    function test_whenStartNotLessThanEnd_revert() external {
        (uint256 s, uint256 e, uint256 p, uint256 c) = _params(10, 1 days, 0.1 ether, 1_000_000 ether);

        vm.prank(deployer);
        vm.expectRevert(Errors.InvalidTimeframe.selector);
        tokenSale.setNewRound(e, s, p, c);
    }

    function test_whenStartLessBlockTimestamp_revert() external {
        (uint256 s, uint256 e, uint256 p, uint256 c) = _params(10, 1 days, 0.1 ether, 1_000_000 ether);

        vm.prank(deployer);
        vm.expectRevert(Errors.InvalidTimeframe.selector);
        tokenSale.setNewRound(s - 1 hours, e, p, c);
    }

    function test_whenZeroPrice_revert() external {
        (uint256 s, uint256 e,, uint256 c) = _params(10, 1 days, 0, 1_000_000 ether);

        vm.prank(deployer);
        vm.expectRevert(Errors.ZeroAmount.selector);
        tokenSale.setNewRound(s, e, 0, c);
    }

    function test_whenZeroCap_revert() external {
        (uint256 s, uint256 e, uint256 p,) = _params(10, 1 days, 0.1 ether, 0);

        vm.prank(deployer);
        vm.expectRevert(Errors.ZeroAmount.selector);
        tokenSale.setNewRound(s, e, p, 0);
    }

    function test_whenExceedingMaxRounds_revert() external {
        (uint256 s, uint256 e, uint256 p, uint256 c) = _params(10, 1 days, 0.1 ether, 1_000_000 ether);
        vm.prank(deployer);
        tokenSale.setNewRound(s, e, p, c);

        for (uint256 i = 1; i < Constants.MAX_ROUNDS; i++) {
            (uint256 si, uint256 ei, uint256 pi, uint256 ci) =
                _params(10 + i, 1 days, 0.1 ether + i, 1_000_000 ether + i);
            vm.prank(deployer);
            tokenSale.setNewRound(si, ei, pi, ci);
            assertEq(tokenSale.currentRoundId(), i);
        }
        assertEq(tokenSale.currentRoundId(), Constants.MAX_ROUNDS - 1);

        (uint256 sn, uint256 en, uint256 pn, uint256 cn) =
            _params(10 + Constants.MAX_ROUNDS, 1 days, 0.5 ether, 2_000_000 ether);
        vm.prank(deployer);
        vm.expectRevert(Errors.CapReached.selector);
        tokenSale.setNewRound(sn, en, pn, cn);
    }

    function test_whenCalledByNonOwner_revert() external {
        (uint256 s, uint256 e, uint256 p, uint256 c) = _params(10, 1 days, 0.1 ether, 1_000_000 ether);

        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, bob));
        tokenSale.setNewRound(s, e, p, c);
    }

    function _params(uint256 startOffset, uint256 duration, uint256 price, uint256 cap)
        internal
        view
        returns (uint256 startTime, uint256 endTime, uint256 tokenPrice, uint256 capTotal)
    {
        startTime = block.timestamp + startOffset;
        endTime = startTime + duration;
        tokenPrice = price;
        capTotal = cap;
    }
}
