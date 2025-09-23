// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { AggregatorV3Interface } from "@chainlink-contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import { INITIAL_ADMIN, PLATFORM_TREASURY_WALLET } from "script/lib/DataStore.sol";
import { Errors } from "src/lib/Errors.sol";
import { Constants } from "src/lib/Constants.sol";
import { IICOSale } from "src/interfaces/IICOSale.sol";

import { ICOSaleTest } from "test/ICOSaleTest.sol";

contract ICOSaleBuyETHTest is ICOSaleTest {
    uint256 internal OWNER_PK;
    address internal NEW_OWNER;

    uint256 internal roundPrice;
    uint256 internal roundCap;

    function setUp() public {
        fixture();

        OWNER_PK = 0xA11CE;
        NEW_OWNER = vm.addr(OWNER_PK);

        vm.prank(INITIAL_ADMIN);
        tokenSale.transferOwnership(NEW_OWNER);

        roundPrice = 0.02 ether;
        roundCap = 10_000_000 ether;

        uint256 start = block.timestamp + 1;
        uint256 end = start + 7 days;

        vm.prank(NEW_OWNER);
        tokenSale.setNewRound(start, end, roundPrice, roundCap);

        vm.warp(start);

        _ensureFeedTimestampNotAhead();
    }

    function test_whenAllValid_noReferral_success() external {
        uint256 weiAmount = _usdToWei(20 ether);

        (IICOSale.PurchaseDetails memory pd, bytes memory sig) = _prepare(weiAmount, "", 0, alice);

        uint256 treasuryBefore = PLATFORM_TREASURY_WALLET.balance;
        uint256 refundableBefore = tokenSale.refundable(alice, Constants.WETH);
        uint256 totalUsdBefore = tokenSale.totalUsdRaised();
        (,,,, uint256 soldBefore,) = tokenSale.rounds(tokenSale.currentRoundId());
        uint256 buyerRoundBefore = tokenSale.roundBuyerAllocation(tokenSale.currentRoundId(), alice);
        uint256 buyerTotalBefore = tokenSale.totalBuyerAllocation(alice);
        uint256 totalAllocBefore = tokenSale.totalAllocatedTokens();

        uint256 usdValue = _weiToUsd(weiAmount);
        uint256 base = usdValue * 1 ether / roundPrice;

        vm.prank(alice);
        tokenSale.buyETH{ value: weiAmount }(pd, sig);

        assertEq(PLATFORM_TREASURY_WALLET.balance, treasuryBefore + weiAmount);
        assertEq(tokenSale.refundable(alice, Constants.WETH), refundableBefore + weiAmount);
        assertEq(tokenSale.totalUsdRaised(), totalUsdBefore + usdValue);

        (,,,, uint256 soldAfter, bool active) = tokenSale.rounds(tokenSale.currentRoundId());
        assertTrue(active);
        assertEq(soldAfter, soldBefore + base);

        assertEq(tokenSale.roundBuyerAllocation(tokenSale.currentRoundId(), alice), buyerRoundBefore + base);
        assertEq(tokenSale.totalBuyerAllocation(alice), buyerTotalBefore + base);
        assertEq(tokenSale.totalAllocatedTokens(), totalAllocBefore + base);
        assertEq(tokenSale.nonces(alice), pd.nonce + 1);
    }

    function test_whenAllValid_withReferral_success() external {
        vm.prank(NEW_OWNER);
        tokenSale.setReferralTypeBps(1, 1000);

        uint256 weiAmount = _usdToWei(50 ether);

        string memory code = "INFL-abc";
        (IICOSale.PurchaseDetails memory pd, bytes memory sig) = _prepare(weiAmount, code, 1, alice);

        uint256 usdValue = _weiToUsd(weiAmount);
        uint256 base = usdValue * 1 ether / roundPrice;
        uint256 refBonus = base * 1000 / Constants.BASIS_FEE_DIVISOR;

        uint256 refUsdBefore = tokenSale.refTotalUsd(code);
        uint256 refBonusBefore = tokenSale.refTotalBonusTokens(code);

        vm.prank(alice);
        tokenSale.buyETH{ value: weiAmount }(pd, sig);

        assertEq(tokenSale.refTotalUsd(code), refUsdBefore + usdValue);
        assertEq(tokenSale.refTotalBonusTokens(code), refBonusBefore + refBonus);
    }

    function test_whenSaleFinalized_revert() external {
        vm.prank(NEW_OWNER);
        tokenSale.finalizeSale();

        uint256 weiAmount = _usdToWei(20 ether);
        (IICOSale.PurchaseDetails memory pd, bytes memory sig) = _prepare(weiAmount, "", 0, alice);

        vm.prank(alice);
        vm.expectRevert(Errors.SaleAlreadyFinalized.selector);
        tokenSale.buyETH{ value: weiAmount }(pd, sig);
    }

    function test_whenMsgValueZeroOrMismatch_revert() external {
        uint256 weiAmount = _usdToWei(15 ether);

        (IICOSale.PurchaseDetails memory pd, bytes memory sig) = _prepare(weiAmount, "", 0, alice);
        vm.prank(alice);
        vm.expectRevert(Errors.ZeroAmount.selector);
        tokenSale.buyETH{ value: weiAmount - 1 }(pd, sig);

        pd.amount = 0;
        sig = _signPurchase(OWNER_PK, pd);
        vm.prank(alice);
        vm.expectRevert(Errors.ZeroAmount.selector);
        tokenSale.buyETH{ value: 0 }(pd, sig);
    }

    function test_whenAssetNotWETH_revert() external {
        uint256 weiAmount = _usdToWei(12 ether);

        IICOSale.PurchaseDetails memory pd = IICOSale.PurchaseDetails({
            refCode: "",
            refType: 0,
            buyer: alice,
            asset: Constants.USDC,
            amount: weiAmount,
            roundId: tokenSale.currentRoundId(),
            nonce: tokenSale.nonces(alice),
            deadline: block.timestamp + 1 days
        });
        bytes memory sig = _signPurchase(OWNER_PK, pd);

        vm.prank(alice);
        vm.expectRevert(Errors.NotAcceptedAsset.selector);
        tokenSale.buyETH{ value: weiAmount }(pd, sig);
    }

    function test_whenReferralTypeProvidedButEmptyCode_revert() external {
        uint256 weiAmount = _usdToWei(12 ether);

        (IICOSale.PurchaseDetails memory pd, bytes memory sig) = _prepare(weiAmount, "", 1, alice);
        vm.prank(alice);
        vm.expectRevert(Errors.InvalidReferralType.selector);
        tokenSale.buyETH{ value: weiAmount }(pd, sig);
    }

    function test_whenReferralTypeUnknown_revert() external {
        uint256 weiAmount = _usdToWei(12 ether);

        (IICOSale.PurchaseDetails memory pd, bytes memory sig) = _prepare(weiAmount, "X", 9, alice);
        vm.prank(alice);
        vm.expectRevert(Errors.InvalidReferralType.selector);
        tokenSale.buyETH{ value: weiAmount }(pd, sig);
    }

    function test_whenBuyerMismatch_revert() external {
        uint256 weiAmount = _usdToWei(12 ether);

        IICOSale.PurchaseDetails memory pd = IICOSale.PurchaseDetails({
            refCode: "",
            refType: 0,
            buyer: alice,
            asset: Constants.WETH,
            amount: weiAmount,
            roundId: tokenSale.currentRoundId(),
            nonce: tokenSale.nonces(alice),
            deadline: block.timestamp + 1 days
        });
        bytes memory sig = _signPurchase(OWNER_PK, pd);

        deal(bob, 100 ether);
        vm.prank(bob);
        vm.expectRevert(Errors.NotBuyer.selector);
        tokenSale.buyETH{ value: weiAmount }(pd, sig);
    }

    function test_whenRoundIdMismatch_revert() external {
        uint256 weiAmount = _usdToWei(12 ether);

        (IICOSale.PurchaseDetails memory pd,) = _prepare(weiAmount, "", 0, alice);
        pd.roundId = tokenSale.currentRoundId() + 1;
        bytes memory sig = _signPurchase(OWNER_PK, pd);

        vm.prank(alice);
        vm.expectRevert(Errors.InactiveRound.selector);
        tokenSale.buyETH{ value: weiAmount }(pd, sig);
    }

    function test_whenNonceMismatch_revert() external {
        uint256 weiAmount = _usdToWei(12 ether);

        (IICOSale.PurchaseDetails memory pd,) = _prepare(weiAmount, "", 0, alice);
        pd.nonce = pd.nonce + 1;
        bytes memory sig = _signPurchase(OWNER_PK, pd);

        vm.prank(alice);
        vm.expectRevert(Errors.NonceMismatch.selector);
        tokenSale.buyETH{ value: weiAmount }(pd, sig);
    }

    function test_whenDeadlineExpired_revert() external {
        uint256 weiAmount = _usdToWei(12 ether);

        (IICOSale.PurchaseDetails memory pd,) = _prepare(weiAmount, "", 0, alice);
        pd.deadline = block.timestamp - 1;
        bytes memory sig = _signPurchase(OWNER_PK, pd);

        vm.prank(alice);
        vm.expectRevert(Errors.ExpiredSignature.selector);
        tokenSale.buyETH{ value: weiAmount }(pd, sig);
    }

    function test_whenSignerNotOwner_revert() external {
        uint256 BAD_PK = 0xC0FFEE;
        address badOwner = vm.addr(BAD_PK);
        assertTrue(badOwner != NEW_OWNER);

        uint256 weiAmount = _usdToWei(12 ether);

        IICOSale.PurchaseDetails memory pd = IICOSale.PurchaseDetails({
            refCode: "",
            refType: 0,
            buyer: alice,
            asset: Constants.WETH,
            amount: weiAmount,
            roundId: tokenSale.currentRoundId(),
            nonce: tokenSale.nonces(alice),
            deadline: block.timestamp + 1 days
        });

        bytes32 ds = _domainSeparator();
        bytes32 sh = _structHash(pd);
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", ds, sh));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(BAD_PK, digest);
        bytes memory badSig = abi.encodePacked(r, s, v);

        vm.prank(alice);
        vm.expectRevert(Errors.InvalidSignature.selector);
        tokenSale.buyETH{ value: weiAmount }(pd, badSig);
    }

    function test_whenRoundInactive_revert() external {
        uint256 start2 = block.timestamp + 10;
        uint256 end2 = start2 + 1 days;

        vm.prank(NEW_OWNER);
        tokenSale.setNewRound(start2, end2, roundPrice, roundCap);

        uint256 weiAmount = _usdToWei(12 ether);

        IICOSale.PurchaseDetails memory pd = IICOSale.PurchaseDetails({
            refCode: "",
            refType: 0,
            buyer: alice,
            asset: Constants.WETH,
            amount: weiAmount,
            roundId: 0,
            nonce: tokenSale.nonces(alice),
            deadline: block.timestamp + 1 days
        });
        bytes memory sig = _signPurchase(OWNER_PK, pd);

        vm.prank(alice);
        vm.expectRevert(Errors.InactiveRound.selector);
        tokenSale.buyETH{ value: weiAmount }(pd, sig);
    }

    function test_whenOutsideTimeframe_revert() external {
        (, uint256 end,,,,) = tokenSale.rounds(tokenSale.currentRoundId());
        vm.warp(end + 1);
        _ensureFeedTimestampNotAhead();

        (IICOSale.PurchaseDetails memory pd, bytes memory sig) = _prepare(1 ether, "", 0, alice);

        vm.prank(alice);
        vm.expectRevert(Errors.InvalidTimeframe.selector);
        tokenSale.buyETH{ value: 1 ether }(pd, sig);
    }

    function test_whenUnderMinUsd_revert() external {
        vm.prank(NEW_OWNER);
        tokenSale.setMinUsdPerTx(100 ether);

        uint256 weiAmount = _usdToWei(50 ether);

        (IICOSale.PurchaseDetails memory pd, bytes memory sig) = _prepare(weiAmount, "", 0, alice);
        vm.prank(alice);
        vm.expectRevert(Errors.UnderMin.selector);
        tokenSale.buyETH{ value: weiAmount }(pd, sig);
    }

    function test_whenExceedsWalletCap_revert() external {
        vm.deal(alice, 55_000 ether);

        vm.prank(NEW_OWNER);
        tokenSale.setMinUsdPerTx(1 ether);

        uint256 price = oracle.getPriceInUSD(Constants.WETH);
        uint256 maxPerWallet = Constants.MAX_USD_PER_WALLET;

        uint256 wei1 = (maxPerWallet - 1 ether) * 1 ether / price;
        (IICOSale.PurchaseDetails memory pd1, bytes memory sig1) = _prepare(wei1, "", 0, alice);
        vm.prank(alice);
        tokenSale.buyETH{ value: wei1 }(pd1, sig1);

        uint256 wei2 = 2 ether * 1 ether / price;
        (IICOSale.PurchaseDetails memory pd2, bytes memory sig2) = _prepare(wei2, "", 0, alice);

        vm.prank(alice);
        vm.expectRevert(Errors.WalletCapExceeded.selector);
        tokenSale.buyETH{ value: wei2 }(pd2, sig2);
    }

    function test_whenExceedsRoundCap_revert() external {
        uint256 start2 = block.timestamp + 1;
        uint256 end2 = start2 + 3 days;
        uint256 tinyCap = 100 ether;
        uint256 pricePerToken = 0.01 ether;

        vm.prank(NEW_OWNER);
        tokenSale.setNewRound(start2, end2, pricePerToken, tinyCap);
        vm.warp(start2);

        uint256 price = oracle.getPriceInUSD(Constants.WETH);
        uint256 usd1 = (tinyCap - 1 ether) * pricePerToken / 1 ether;
        uint256 wei1 = (usd1 * 1 ether) / price;

        (IICOSale.PurchaseDetails memory pd1, bytes memory sig1) = _prepare(wei1, "", 0, alice);
        vm.prank(alice);
        tokenSale.buyETH{ value: wei1 }(pd1, sig1);

        uint256 usd2 = 2 ether * pricePerToken / 1 ether;
        uint256 wei2 = usd2 * 1 ether / price;

        (IICOSale.PurchaseDetails memory pd2, bytes memory sig2) = _prepare(wei2, "", 0, alice);
        vm.prank(alice);
        vm.expectRevert(Errors.CapReached.selector);
        tokenSale.buyETH{ value: wei2 }(pd2, sig2);
    }

    function _domainSeparator() internal view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("ICOSale")),
                keccak256(bytes("v1")),
                block.chainid,
                address(tokenSale)
            )
        );
    }

    function _structHash(IICOSale.PurchaseDetails memory pd) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                Constants._REFERRAL_TYPEHASH,
                pd.refCode,
                pd.refType,
                pd.buyer,
                pd.asset,
                pd.amount,
                pd.roundId,
                pd.nonce,
                pd.deadline
            )
        );
    }

    function _signPurchase(uint256 pk, IICOSale.PurchaseDetails memory pd) internal view returns (bytes memory) {
        bytes32 ds = _domainSeparator();
        bytes32 sh = _structHash(pd);
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", ds, sh));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        return abi.encodePacked(r, s, v);
    }

    function _usdToWei(uint256 usdValue) internal view returns (uint256) {
        uint256 price = oracle.getPriceInUSD(Constants.WETH);
        return (usdValue * 1 ether) / price;
    }

    function _weiToUsd(uint256 weiAmount) internal view returns (uint256) {
        uint256 price = oracle.getPriceInUSD(Constants.WETH);
        return (weiAmount * price) / 1 ether;
    }

    function _prepare(uint256 weiAmount, string memory refCode, uint8 refType, address who)
        internal
        view
        returns (IICOSale.PurchaseDetails memory pd, bytes memory sig)
    {
        pd = IICOSale.PurchaseDetails({
            refCode: refCode,
            refType: refType,
            buyer: who,
            asset: Constants.WETH,
            amount: weiAmount,
            roundId: tokenSale.currentRoundId(),
            nonce: tokenSale.nonces(who),
            deadline: block.timestamp + 1 days
        });
        sig = _signPurchase(OWNER_PK, pd);
    }

    function _ensureFeedTimestampNotAhead() internal {
        address feedAddress = oracle.priceFeeds(Constants.WETH);
        (,,, uint256 updatedAt,) = AggregatorV3Interface(feedAddress).latestRoundData();
        if (block.timestamp < updatedAt) {
            vm.warp(updatedAt);
        }
    }
}
