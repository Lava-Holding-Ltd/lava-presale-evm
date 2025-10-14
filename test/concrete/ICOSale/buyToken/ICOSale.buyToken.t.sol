// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { AggregatorV3Interface } from "@chainlink-contracts-0.8.0/src/v0.8/interfaces/AggregatorV3Interface.sol";

import { Errors } from "src/lib/Errors.sol";
import { Constants } from "src/lib/Constants.sol";
import { MockERC20 } from "src/mock/MockERC20.sol";
import { IICOSale } from "src/interfaces/IICOSale.sol";

import { ICOSaleTest } from "test/ICOSaleTest.sol";

contract ICOSaleBuyTokenTest is ICOSaleTest {
    uint256 internal constant ONE_USDC = 1e6;
    uint256 internal constant USDC_TO_18 = 1e12;

    uint256 internal constant USDC_AMOUNT = 12 ether / USDC_TO_18;

    uint256 internal OWNER_PK;
    address internal NEW_OWNER;

    uint256 internal roundPrice;
    uint256 internal roundCap;

    function setUp() public {
        fixture();

        OWNER_PK = 0xA11CE;
        NEW_OWNER = vm.addr(OWNER_PK);
        vm.prank(deployer);
        tokenSale.transferOwnership(NEW_OWNER);

        roundPrice = 0.02 ether;
        roundCap = 10_000_000 ether;

        uint256 start = block.timestamp + 2;
        uint256 end = start + 14 days;

        vm.prank(NEW_OWNER);
        tokenSale.setNewRound(start, end, roundPrice, roundCap);
        vm.warp(start);

        deal(Constants.USDC, alice, 10_000_000 * ONE_USDC);
        vm.prank(alice);
        IERC20(Constants.USDC).approve(address(tokenSale), type(uint256).max);

        deal(Constants.USDC, bob, 10_000_000 * ONE_USDC);
        vm.prank(bob);
        IERC20(Constants.USDC).approve(address(tokenSale), type(uint256).max);

        _ensureFeedTimestampNotAhead();
    }

    function test_whenAllValid_noReferral_success() external {
        (IICOSale.PurchaseDetails memory pd, bytes memory sig) =
            _prepareToken(Constants.USDC, USDC_AMOUNT, keccak256(bytes("")), 0, alice);

        uint256 treasBefore = IERC20(Constants.USDC).balanceOf(deployer);
        uint256 refBefore = tokenSale.refundable(alice, Constants.USDC);
        uint256 totalBefore = tokenSale.totalUsdRaised();
        (,,,, uint256 soldBefore,) = tokenSale.rounds(tokenSale.currentRoundId());
        uint256 buyerRoundBefore = tokenSale.roundBuyerAllocation(tokenSale.currentRoundId(), alice);
        uint256 buyerTotalBefore = tokenSale.totalBuyerAllocation(alice);
        uint256 allocBefore = tokenSale.totalAllocatedTokens();

        uint256 normalized = USDC_AMOUNT * USDC_TO_18;
        uint256 base = normalized * 1 ether / roundPrice;

        vm.prank(alice);
        tokenSale.buyToken(pd, sig, "");

        assertEq(IERC20(Constants.USDC).balanceOf(deployer), treasBefore + USDC_AMOUNT);
        assertEq(tokenSale.refundable(alice, Constants.USDC), refBefore + USDC_AMOUNT);
        assertEq(tokenSale.totalUsdRaised(), totalBefore + normalized);

        (,,,, uint256 soldAfter, bool active) = tokenSale.rounds(tokenSale.currentRoundId());
        assertTrue(active);
        assertEq(soldAfter, soldBefore + base);

        assertEq(tokenSale.roundBuyerAllocation(tokenSale.currentRoundId(), alice), buyerRoundBefore + base);
        assertEq(tokenSale.totalBuyerAllocation(alice), buyerTotalBefore + base);
        assertEq(tokenSale.totalAllocatedTokens(), allocBefore + base);
        assertEq(tokenSale.nonces(alice), pd.nonce + 1);
    }

    function test_whenAllValid_withReferral_success() external {
        vm.prank(NEW_OWNER);
        tokenSale.setReferralTypeBps(1, 1000);

        string memory code = "INFL-abc";
        (IICOSale.PurchaseDetails memory pd, bytes memory sig) =
            _prepareToken(Constants.USDC, USDC_AMOUNT, keccak256(bytes(code)), 1, alice);

        uint256 normalized = USDC_AMOUNT * USDC_TO_18;
        uint256 base = normalized * 1 ether / roundPrice;
        uint256 refBonus = (base * 1000) / Constants.BASIS_FEE_DIVISOR;

        uint256 refUsdBefore = tokenSale.refTotalUsd(code);
        uint256 refBonusBefore = tokenSale.refTotalBonusTokens(code);

        vm.prank(alice);
        tokenSale.buyToken(pd, sig, code);

        assertEq(tokenSale.refTotalUsd(code), refUsdBefore + normalized);
        assertEq(tokenSale.refTotalBonusTokens(code), refBonusBefore + refBonus);
    }

    function test_whenProvidedRefCode_NoReferral_revert() external {
        string memory code = "INFL-abc";
        (IICOSale.PurchaseDetails memory pd, bytes memory sig) =
            _prepareToken(Constants.USDC, USDC_AMOUNT, keccak256(bytes(code)), 0, alice);

        vm.prank(alice);
        vm.expectRevert(Errors.InvalidReferralCode.selector);
        tokenSale.buyToken(pd, sig, code);
    }

    function test_whenSaleFinalized_revert() external {
        _createRounds(Constants.MAX_ROUNDS - 1);

        vm.prank(NEW_OWNER);
        tokenSale.finalizeSale();

        (IICOSale.PurchaseDetails memory pd, bytes memory sig) =
            _prepareToken(Constants.USDC, USDC_AMOUNT, keccak256(bytes("")), 0, alice);

        vm.prank(alice);
        vm.expectRevert(Errors.SaleAlreadyFinalized.selector);
        tokenSale.buyToken(pd, sig, "");
    }

    function test_whenAmountZero_revert() external {
        (IICOSale.PurchaseDetails memory pd, bytes memory sig) =
            _prepareToken(Constants.USDC, 0, keccak256(bytes("")), 0, alice);

        vm.prank(alice);
        vm.expectRevert(Errors.ZeroAmount.selector);
        tokenSale.buyToken(pd, sig, "");
    }

    function test_whenAssetZeroOrNotApproved_revert() external {
        IICOSale.PurchaseDetails memory pd0 = _buildPD(address(0), USDC_AMOUNT, keccak256(bytes("")), 0, alice);
        bytes memory sig0 = _signPurchase(OWNER_PK, pd0);
        vm.prank(alice);
        vm.expectRevert(Errors.NotAcceptedAsset.selector);
        tokenSale.buyToken(pd0, sig0, "");

        MockERC20 fake = new MockERC20("Fake Token", "FAKE", 100_000 ether, 6);
        fake.mint(alice, 1_000_000e6);

        vm.prank(alice);
        fake.approve(address(tokenSale), type(uint256).max);

        IICOSale.PurchaseDetails memory pd1 = _buildPD(address(fake), USDC_AMOUNT, keccak256(bytes("")), 0, alice);
        bytes memory sig1 = _signPurchase(OWNER_PK, pd1);
        vm.prank(alice);
        vm.expectRevert(Errors.NotAcceptedAsset.selector);
        tokenSale.buyToken(pd1, sig1, "");
    }

    function test_whenRefTypeProvidedButEmptyCode_revert() external {
        (IICOSale.PurchaseDetails memory pd, bytes memory sig) =
            _prepareToken(Constants.USDC, USDC_AMOUNT, keccak256(bytes("")), uint8(1), alice);

        vm.prank(alice);
        vm.expectRevert(Errors.InvalidReferralType.selector);
        tokenSale.buyToken(pd, sig, "");
    }

    function test_whenRefTypeUnknown_revert() external {
        (IICOSale.PurchaseDetails memory pd, bytes memory sig) =
            _prepareToken(Constants.USDC, USDC_AMOUNT, keccak256(bytes("X")), uint8(9), alice);

        vm.prank(alice);
        vm.expectRevert(Errors.InvalidReferralType.selector);
        tokenSale.buyToken(pd, sig, "X");
    }

    function test_whenBuyerMismatch_revert() external {
        IICOSale.PurchaseDetails memory pd = _buildPD(Constants.USDC, USDC_AMOUNT, keccak256(bytes("")), 0, alice);
        bytes memory sig = _signPurchase(OWNER_PK, pd);

        vm.prank(bob);
        vm.expectRevert(Errors.NotBuyer.selector);
        tokenSale.buyToken(pd, sig, "");
    }

    function test_whenRoundIdMismatch_revert() external {
        (IICOSale.PurchaseDetails memory pd,) =
            _prepareToken(Constants.USDC, USDC_AMOUNT, keccak256(bytes("")), 0, alice);
        pd.roundId = tokenSale.currentRoundId() + 1;
        bytes memory sig = _signPurchase(OWNER_PK, pd);

        vm.prank(alice);
        vm.expectRevert(Errors.InactiveRound.selector);
        tokenSale.buyToken(pd, sig, "");
    }

    function test_whenNonceMismatch_revert() external {
        (IICOSale.PurchaseDetails memory pd,) =
            _prepareToken(Constants.USDC, USDC_AMOUNT, keccak256(bytes("")), 0, alice);
        pd.nonce = pd.nonce + 1;
        bytes memory sig = _signPurchase(OWNER_PK, pd);

        vm.prank(alice);
        vm.expectRevert(Errors.NonceMismatch.selector);
        tokenSale.buyToken(pd, sig, "");
    }

    function test_whenDeadlineExpired_revert() external {
        (IICOSale.PurchaseDetails memory pd,) =
            _prepareToken(Constants.USDC, USDC_AMOUNT, keccak256(bytes("")), 0, alice);
        pd.deadline = block.timestamp - 1;
        bytes memory sig = _signPurchase(OWNER_PK, pd);

        vm.prank(alice);
        vm.expectRevert(Errors.ExpiredSignature.selector);
        tokenSale.buyToken(pd, sig, "");
    }

    function test_whenSignerNotOwner_revert() external {
        uint256 BAD_PK = 0xC0FFEE;
        address badOwner = vm.addr(BAD_PK);
        assertTrue(badOwner != NEW_OWNER);

        IICOSale.PurchaseDetails memory pd = _buildPD(Constants.USDC, USDC_AMOUNT, keccak256(bytes("")), 0, alice);

        bytes32 ds = _domainSeparator();
        bytes32 sh = _structHash(pd);
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", ds, sh));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(BAD_PK, digest);
        bytes memory badSig = abi.encodePacked(r, s, v);

        vm.prank(alice);
        vm.expectRevert(Errors.InvalidSignature.selector);
        tokenSale.buyToken(pd, badSig, "");
    }

    function test_whenRoundInactive_revert() external {
        uint256 start2 = block.timestamp + 10;
        uint256 end2 = start2 + 1 days;
        vm.prank(NEW_OWNER);
        tokenSale.setNewRound(start2, end2, roundPrice, roundCap);

        IICOSale.PurchaseDetails memory pd = IICOSale.PurchaseDetails({
            refCode: keccak256(bytes("")),
            refType: 0,
            buyer: alice,
            asset: Constants.USDC,
            amount: USDC_AMOUNT,
            roundId: 0,
            nonce: tokenSale.nonces(alice),
            deadline: block.timestamp + 1 days
        });
        bytes memory sig = _signPurchase(OWNER_PK, pd);

        vm.prank(alice);
        vm.expectRevert(Errors.InactiveRound.selector);
        tokenSale.buyToken(pd, sig, "");
    }

    function test_whenOutsideTimeframe_revert() external {
        (, uint256 end,,,,) = tokenSale.rounds(tokenSale.currentRoundId());
        vm.warp(end + 1);

        (IICOSale.PurchaseDetails memory pd, bytes memory sig) =
            _prepareToken(Constants.USDC, USDC_AMOUNT, keccak256(bytes("")), 0, alice);

        vm.prank(alice);
        vm.expectRevert(Errors.InvalidTimeframe.selector);
        tokenSale.buyToken(pd, sig, "");
    }

    function test_whenUnderMinUsd_revert() external {
        vm.prank(NEW_OWNER);
        tokenSale.setMinUsdPerTx(100 ether);

        (IICOSale.PurchaseDetails memory pd, bytes memory sig) =
            _prepareToken(Constants.USDC, USDC_AMOUNT, keccak256(bytes("")), 0, alice);

        vm.prank(alice);
        vm.expectRevert(Errors.UnderMin.selector);
        tokenSale.buyToken(pd, sig, "");
    }

    function test_whenExceedsWalletCap_revert() external {
        vm.prank(NEW_OWNER);
        tokenSale.setMinUsdPerTx(1 ether);

        uint256 maxPerWallet = Constants.MAX_USD_PER_WALLET;
        uint256 usd1 = maxPerWallet - 1 ether;
        uint256 amt1 = usd1 / USDC_TO_18;
        (IICOSale.PurchaseDetails memory pd1, bytes memory sig1) =
            _prepareToken(Constants.USDC, amt1, keccak256(bytes("")), 0, alice);
        vm.prank(alice);
        tokenSale.buyToken(pd1, sig1, "");

        uint256 usd2 = 2 ether;
        uint256 amt2 = usd2 / USDC_TO_18;
        (IICOSale.PurchaseDetails memory pd2, bytes memory sig2) =
            _prepareToken(Constants.USDC, amt2, keccak256(bytes("")), 0, alice);

        vm.prank(alice);
        vm.expectRevert(Errors.WalletCapExceeded.selector);
        tokenSale.buyToken(pd2, sig2, "");
    }

    function test_whenExceedsHardCap_revert() external {
        uint256 start2 = block.timestamp + 1;
        uint256 end2 = start2 + 30 days;
        uint256 bigCap = tokenSale.MAX_TOTAL_ALLOCATION_TOKENS();
        vm.prank(NEW_OWNER);
        tokenSale.setNewRound(start2, end2, roundPrice, bigCap);
        vm.warp(start2);

        uint256 hardCap = Constants.HARD_CAP_USD;
        uint256 perWallet = Constants.MAX_USD_PER_WALLET - 1;

        uint256 i;
        while (true) {
            uint256 raised = tokenSale.totalUsdRaised();
            if (raised >= hardCap) break;

            uint256 gap = hardCap - raised;
            if (gap <= 2 ether) break;

            uint256 usdThis = gap > perWallet ? perWallet : (gap - 1 ether);
            address w = vm.addr(uint256(keccak256(abi.encodePacked("hardcap-filler", i++))));

            deal(Constants.USDC, w, 1_000_000 * ONE_USDC);
            vm.prank(w);
            IERC20(Constants.USDC).approve(address(tokenSale), type(uint256).max);

            uint256 amt = usdThis / USDC_TO_18;
            IICOSale.PurchaseDetails memory pd = _buildPD(Constants.USDC, amt, keccak256(bytes("")), 0, w);
            bytes memory sig = _signPurchase(OWNER_PK, pd);

            vm.prank(w);
            tokenSale.buyToken(pd, sig, "");
        }

        uint256 gapNow = hardCap - tokenSale.totalUsdRaised();
        uint256 desiredUsd = (gapNow == 0) ? 1 ether : (gapNow + 10 ether);
        if (desiredUsd > perWallet) desiredUsd = perWallet;

        uint256 amtFinal = desiredUsd / USDC_TO_18;
        deal(Constants.USDC, alice, IERC20(Constants.USDC).balanceOf(alice) + amtFinal);
        vm.prank(alice);
        IERC20(Constants.USDC).approve(address(tokenSale), type(uint256).max);

        (IICOSale.PurchaseDetails memory pdF, bytes memory sigF) =
            _prepareToken(Constants.USDC, amtFinal, keccak256(bytes("")), 0, alice);

        vm.prank(alice);
        vm.expectRevert(Errors.HardCapExceeded.selector);
        tokenSale.buyToken(pdF, sigF, "");
    }

    function test_whenExceedsRoundCap_revert() external {
        uint256 start2 = block.timestamp + 1;
        uint256 end2 = start2 + 3 days;
        uint256 tinyCap = 100 ether;
        uint256 pricePerToken = 0.01 ether;

        vm.prank(NEW_OWNER);
        tokenSale.setNewRound(start2, end2, pricePerToken, tinyCap);
        vm.warp(start2);

        uint256 usd1 = (tinyCap - 1 ether) * pricePerToken / 1 ether;
        uint256 amt1 = usd1 / USDC_TO_18;

        (IICOSale.PurchaseDetails memory pd1, bytes memory sig1) =
            _prepareToken(Constants.USDC, amt1, keccak256(bytes("")), 0, alice);
        vm.prank(alice);
        tokenSale.buyToken(pd1, sig1, "");

        uint256 usd2 = (2 ether) * pricePerToken / 1 ether;
        uint256 amt2 = usd2 / USDC_TO_18;

        (IICOSale.PurchaseDetails memory pd2, bytes memory sig2) =
            _prepareToken(Constants.USDC, amt2, keccak256(bytes("")), 0, alice);

        vm.prank(alice);
        vm.expectRevert(Errors.CapReached.selector);
        tokenSale.buyToken(pd2, sig2, "");
    }

    function test_whenExceedsGlobalTokenCap_revert() external {
        vm.prank(NEW_OWNER);
        tokenSale.setMinUsdPerTx(1 ether);

        uint256 start2 = block.timestamp + 1;
        uint256 end2 = start2 + 30 days;

        uint256 cheapPrice = 1e14;
        uint256 bigCap = tokenSale.MAX_TOTAL_ALLOCATION_TOKENS();
        vm.prank(NEW_OWNER);
        tokenSale.setNewRound(start2, end2, cheapPrice, bigCap);
        vm.warp(start2);

        address w = vm.addr(uint256(keccak256("global-cap-buyer")));
        deal(Constants.USDC, w, 100_000_000 * ONE_USDC);
        vm.prank(w);
        IERC20(Constants.USDC).approve(address(tokenSale), type(uint256).max);

        uint256 maxTok = tokenSale.MAX_TOTAL_ALLOCATION_TOKENS();
        uint256 targetTokens = maxTok - 1 ether;
        uint256 usdForTarget = (targetTokens * cheapPrice) / 1 ether;
        uint256 amt = usdForTarget / USDC_TO_18;

        IICOSale.PurchaseDetails memory pd = _buildPD(Constants.USDC, amt, keccak256(bytes("")), 0, w);
        bytes memory sig = _signPurchase(OWNER_PK, pd);
        vm.prank(w);
        tokenSale.buyToken(pd, sig, "");

        uint256 usd2 = 1 ether;
        uint256 amt2 = usd2 / USDC_TO_18;
        (IICOSale.PurchaseDetails memory pd2, bytes memory sig2) =
            _prepareToken(Constants.USDC, amt2, keccak256(bytes("")), 0, alice);

        vm.prank(alice);
        vm.expectRevert(Errors.CapReached.selector);
        tokenSale.buyToken(pd2, sig2, "");
    }

    function _prepareToken(address asset, uint256 tokenAmount, bytes32 refCode, uint8 refType, address who)
        internal
        returns (IICOSale.PurchaseDetails memory pd, bytes memory sig)
    {
        pd = _buildPD(asset, tokenAmount, refCode, refType, who);
        sig = _signPurchase(OWNER_PK, pd);

        if (asset == Constants.USDC) {
            vm.prank(who);
            IERC20(Constants.USDC).approve(address(tokenSale), type(uint256).max);
        }
    }

    function _buildPD(address asset, uint256 amount_, bytes32 refCode, uint8 refType, address who)
        internal
        view
        returns (IICOSale.PurchaseDetails memory pd)
    {
        pd = IICOSale.PurchaseDetails({
            refCode: refCode,
            refType: refType,
            buyer: who,
            asset: asset,
            amount: amount_,
            roundId: tokenSale.currentRoundId(),
            nonce: tokenSale.nonces(who),
            deadline: block.timestamp + 1 days
        });
    }

    function _domainSeparator() internal view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("ICOSale")),
                keccak256(bytes("1")),
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

    function _ensureFeedTimestampNotAhead() internal {
        address feedAddress = oracle.priceFeeds(Constants.WETH);
        (,,, uint256 updatedAt,) = AggregatorV3Interface(feedAddress).latestRoundData();
        if (block.timestamp < updatedAt) vm.warp(updatedAt);
    }

    function _createRounds(uint256 n) internal {
        uint256 nowTs = block.timestamp;
        for (uint256 i; i < n; i++) {
            uint256 startTime = nowTs + (i + 1) * 1000;
            uint256 endTime = startTime + 100;
            uint256 tokenPrice = 1 ether;
            uint256 capTotal = 1e24 / 10;

            vm.prank(NEW_OWNER);
            tokenSale.setNewRound(startTime, endTime, tokenPrice, capTotal);
        }
    }
}
