// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Nonces } from "@openzeppelin/contracts/utils/Nonces.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { Utils } from "src/lib/Utils.sol";
import { Errors } from "src/lib/Errors.sol";
import { Constants } from "src/lib/Constants.sol";
import { IICOSale } from "src/interfaces/IICOSale.sol";
import { IOracleAdapter } from "src/interfaces/IOracleAdapter.sol";

/// @title The ICOSale Smart Contract
/// @notice This contract manages the ICO sale process, including rounds, purchases, referrals, and refunds
/// @dev The contract uses OpenZeppelin libraries for security and standard functionalities
contract ICOSale is IICOSale, EIP712, Ownable, ReentrancyGuard, Nonces {
    using SafeERC20 for IERC20;

    /// @notice The enum defining the referral types used for categorizing referrals
    /// @param NoReferral Represents no referral used
    /// @param Influencer Represents referrals made by influencers
    /// @param Media Represents referrals made by media partners
    enum RefType {
        NoReferral,
        Influencer,
        Media
    }

    /// @notice The treasury address where funds will be sent
    address public immutable TREASURY_WALLET;

    /// @notice The oracle adapter for fetching price feeds
    IOracleAdapter public immutable ORACLE_ADAPTER;

    /// @notice The maximum number of tokens available for sale
    uint256 public immutable MAX_TOTAL_ALLOCATION_TOKENS;

    /// @notice The minimum USD amount per transaction available for purchase
    uint256 public minUsdPerTx;

    /// @notice The total USD amount raised across all rounds (normalized to 18 decimals)
    uint256 public totalUsdRaised;

    /// @notice The total number of tokens allocated across all buyers and rounds
    /// @dev This value cannot exceed MAX_TOTAL_ALLOCATION_TOKENS
    uint256 public totalAllocatedTokens;

    /// @notice The current round ID
    uint256 public currentRoundId;

    /// @notice The boolean indicating if the sale has been finalized
    /// @dev Once finalized, no more deposits are allowed
    bool public saleFinalized;

    /// @notice The mapping keeps details of each sale round
    /// @dev The general sale parameters are defined in the Round struct, schema: roundId => Round
    mapping(uint256 => Round) public rounds;

    /// @notice The mapping tracks the approved assets for payment
    /// @dev The key is the token address, and the value indicates if it's approved (true) or not (false)
    mapping(address => bool) public isApprovedAsset;

    /// @notice The mapping tracks the total USD amount raised per wallet (normalized to 18 decimals)
    mapping(address => uint256) public walletUsdRaised;

    /// @notice The mapping tracks the allocation per user across all rounds
    /// @dev The schema is: user address => total allocated tokens
    mapping(address => uint256) public totalBuyerAllocation;

    /// @notice The mapping tracks the round-specific allocation per user
    /// @dev The schema is: round ID => user address => allocated tokens in that round
    mapping(uint256 => mapping(address => uint256)) public roundBuyerAllocation;

    /// @notice The mapping tracks refundable amounts per user and asset
    /// @dev The schema is: user address => token address => refundable amount
    mapping(address => mapping(address => uint256)) public refundable;

    /// @notice The mapping tracks referral bonus basis points by referral type
    /// @dev The key is the referral type (e.g., 0 for influencer, 1 for media, etc.), and the value is the bonus in basis points
    mapping(uint8 => uint16) public referralBonusBpsByType;

    /// @notice The mapping tracks total USD raised per referral code (normalized to 18 decimals)
    /// @dev The key is the string of the referral code
    mapping(string => uint256) public refTotalUsd;

    /// @notice The mapping tracks total bonus tokens awarded per referral code
    /// @dev The key is the string of the referral code
    mapping(string => uint256) public refTotalBonusTokens;

    /// @notice Fallback function to receive Ether
    receive() external payable { }

    /// @dev The constructor initializes the contract with essential parameters
    /// @param _owner The owner of the contract
    /// @param _oracle The address of the oracle adapter for price feeds
    /// @param _treasury The address where funds will be sent
    /// @param _maxTotalAllocationTokens The maximum number of tokens available for sale
    constructor(address _owner, address _oracle, address _treasury, uint256 _maxTotalAllocationTokens)
        Ownable(_owner)
        EIP712("ICOSale", "1")
    {
        require(_treasury != address(0) && _oracle != address(0), Errors.ZeroAddress());
        require(_maxTotalAllocationTokens != 0, Errors.ZeroAmount());

        TREASURY_WALLET = _treasury;
        ORACLE_ADAPTER = IOracleAdapter(_oracle);
        MAX_TOTAL_ALLOCATION_TOKENS = _maxTotalAllocationTokens;

        isApprovedAsset[Constants.WETH] = true;
        isApprovedAsset[Constants.USDC] = true;
        isApprovedAsset[Constants.USDT] = true;

        emit SaleInitialized(_owner, _oracle, _treasury, _maxTotalAllocationTokens);
    }

    /// @inheritdoc IICOSale
    function rescueFunds(address _token, uint256 _amount) external nonReentrant onlyOwner {
        require(_amount != 0, Errors.ZeroAmount());

        if (_token != address(0) && _token != Constants.WETH) {
            IERC20(_token).safeTransfer(TREASURY_WALLET, _amount);
        } else {
            require(_amount <= address(this).balance, Errors.InsufficientBalance());
            Address.sendValue(payable(TREASURY_WALLET), _amount);
        }

        emit FundsRescued(_token, TREASURY_WALLET, _amount, _msgSender());
    }

    /// @inheritdoc IICOSale
    function setMinUsdPerTx(uint256 _minUsdPerTx) external onlyOwner {
        require(_minUsdPerTx != 0, Errors.ZeroAmount());
        minUsdPerTx = _minUsdPerTx;
        emit MinUsdPerTxUpdated(_minUsdPerTx, _msgSender());
    }

    /// @inheritdoc IICOSale
    function setApprovedAsset(address _asset, bool _approved) external onlyOwner {
        require(_asset != address(0), Errors.ZeroAddress());
        require(isApprovedAsset[_asset] != _approved, Errors.IndicatorAlreadySet());
        isApprovedAsset[_asset] = _approved;
        emit PayAssetApprovalSet(_asset, _approved, _msgSender());
    }

    /// @inheritdoc IICOSale
    function setReferralTypeBps(uint8 _refType, uint16 _refPercentage) external onlyOwner {
        require(_refType == uint8(RefType.Influencer) || _refType == uint8(RefType.Media), Errors.InvalidReferralType());
        require(_refPercentage <= Constants.BASIS_FEE_DIVISOR, Errors.InvalidReferralPercentage());
        referralBonusBpsByType[_refType] = _refPercentage;
        emit ReferralTypePercentageUpdated(_refType, _refPercentage, _msgSender());
    }

    /// @inheritdoc IICOSale
    function finalizeSale() external onlyOwner {
        require(!saleFinalized, Errors.SaleAlreadyFinalized());
        saleFinalized = true;
        emit SaleFinalized(totalUsdRaised, _msgSender());
    }

    /// @inheritdoc IICOSale
    function setNewRound(uint256 _startTime, uint256 _endTime, uint256 _tokenPrice, uint256 _capTotal)
        external
        onlyOwner
    {
        require(_startTime != 0 && _endTime != 0 && _startTime < _endTime, Errors.InvalidTimeframe());
        require(_tokenPrice != 0 && _capTotal != 0, Errors.ZeroAmount());

        if (rounds[currentRoundId].active) rounds[currentRoundId].active = false;

        uint256 newId = (rounds[0].startTime == 0 && currentRoundId == 0) ? 0 : currentRoundId + 1;
        require(newId < Constants.MAX_ROUNDS, Errors.CapReached());
        currentRoundId = newId;

        rounds[currentRoundId] = Round({
            startTime: _startTime,
            endTime: _endTime,
            tokenPrice: _tokenPrice,
            capTotal: _capTotal,
            soldTokens: 0,
            active: true
        });

        emit NewRoundSet(newId, _startTime, _endTime, _tokenPrice, _capTotal);
    }

    /// @inheritdoc IICOSale
    function buyETH(PurchaseDetails calldata _ref, bytes calldata _sig, string calldata _refCodeString)
        external
        payable
        nonReentrant
    {
        require(!saleFinalized, Errors.SaleAlreadyFinalized());
        require(msg.value != 0 && msg.value == _ref.amount, Errors.ZeroAmount());
        require(_ref.refCode == keccak256(bytes(_refCodeString)), Errors.InvalidReferralCode());
        require(_ref.asset == Constants.WETH || _ref.asset == address(0), Errors.NotAcceptedAsset());

        if (_ref.refType != uint8(RefType.NoReferral)) {
            require(
                _ref.refCode != keccak256(bytes(""))
                    && (_ref.refType == uint8(RefType.Influencer) || _ref.refType == uint8(RefType.Media)),
                Errors.InvalidReferralType()
            );
        }

        _verifyReferralSignature(_ref, _sig);

        Address.sendValue(payable(TREASURY_WALLET), msg.value);
        refundable[_msgSender()][address(0)] += msg.value;

        _buyChecksAndEffects(_ref.asset, _ref.amount, _msgSender(), _refCodeString, _ref.refType);
    }

    /// @inheritdoc IICOSale
    function buyToken(PurchaseDetails calldata _ref, bytes calldata _sig, string calldata _refCodeString)
        external
        nonReentrant
    {
        require(!saleFinalized, Errors.SaleAlreadyFinalized());
        require(_ref.amount != 0, Errors.ZeroAmount());
        require(_ref.refCode == keccak256(bytes(_refCodeString)), Errors.InvalidReferralCode());
        require(_ref.asset != address(0) && isApprovedAsset[_ref.asset], Errors.NotAcceptedAsset());

        if (_ref.refType != uint8(RefType.NoReferral)) {
            require(
                _ref.refCode != keccak256(bytes(""))
                    && (_ref.refType == uint8(RefType.Influencer) || _ref.refType == uint8(RefType.Media)),
                Errors.InvalidReferralType()
            );
        }

        _verifyReferralSignature(_ref, _sig);

        IERC20(_ref.asset).safeTransferFrom(_msgSender(), TREASURY_WALLET, _ref.amount);
        refundable[_msgSender()][_ref.asset] += _ref.amount;

        _buyChecksAndEffects(_ref.asset, _ref.amount, _msgSender(), _refCodeString, _ref.refType);
    }

    /// @dev Internal function to handle purchase checks and state updates
    /// @param _payAsset The address of the asset used for payment
    /// @param _payAmount The amount of the asset used for payment
    /// @param _buyer The address of the buyer
    /// @param _refCode The referral code used (if any)
    /// @param _refType The type of referral (if any)
    function _buyChecksAndEffects(
        address _payAsset,
        uint256 _payAmount,
        address _buyer,
        string calldata _refCode,
        uint8 _refType
    ) internal {
        Round storage r = rounds[currentRoundId];
        require(r.active, Errors.InactiveRound());
        require(block.timestamp >= r.startTime && block.timestamp <= r.endTime, Errors.InvalidTimeframe());

        if (_payAsset == address(0)) _payAsset = Constants.WETH;

        uint256 normalizedAmount = Utils._normalizeTo18Decimals(_payAsset, _payAmount);
        uint256 priceAsset = ORACLE_ADAPTER.getPriceInUSD(_payAsset);
        uint256 usdValue = normalizedAmount * priceAsset / 1 ether;

        require(usdValue >= minUsdPerTx, Errors.UnderMin());
        require(totalUsdRaised + usdValue <= Constants.HARD_CAP_USD, Errors.HardCapExceeded());
        require(walletUsdRaised[_buyer] + usdValue <= Constants.MAX_USD_PER_WALLET, Errors.WalletCapExceeded());

        uint256 base = usdValue * 1 ether / r.tokenPrice;
        uint256 refBonus =
            (bytes(_refCode).length != 0) ? base * referralBonusBpsByType[_refType] / Constants.BASIS_FEE_DIVISOR : 0;
        uint256 toBuyer = base + refBonus;

        require(toBuyer <= (r.capTotal - r.soldTokens), Errors.CapReached());
        require(toBuyer <= (MAX_TOTAL_ALLOCATION_TOKENS - totalAllocatedTokens), Errors.CapReached());

        totalUsdRaised += usdValue;
        walletUsdRaised[_buyer] += usdValue;

        r.soldTokens += toBuyer;
        roundBuyerAllocation[currentRoundId][_buyer] += toBuyer;
        totalBuyerAllocation[_buyer] += toBuyer;
        totalAllocatedTokens += toBuyer;

        if (bytes(_refCode).length != 0) {
            refTotalUsd[_refCode] += usdValue;
            refTotalBonusTokens[_refCode] += refBonus;
        }

        emit Purchased(
            currentRoundId, _buyer, _refCode, _refType, _payAsset, normalizedAmount, usdValue, base, refBonus, toBuyer
        );
    }

    /// @dev Internal function to verify the referral signature and update the nonce
    /// @param _ref The referral details structure
    /// @param _signature The EIP-712 signature to verify
    function _verifyReferralSignature(PurchaseDetails calldata _ref, bytes calldata _signature) internal {
        require(_ref.buyer == _msgSender(), Errors.NotBuyer());
        require(_ref.roundId == currentRoundId, Errors.InactiveRound());
        require(_ref.nonce == nonces(_ref.buyer), Errors.NonceMismatch());
        require(_ref.deadline >= block.timestamp, Errors.ExpiredSignature());

        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    Constants._REFERRAL_TYPEHASH,
                    _ref.refCode,
                    _ref.refType,
                    _ref.buyer,
                    _ref.asset,
                    _ref.amount,
                    _ref.roundId,
                    _ref.nonce,
                    _ref.deadline
                )
            )
        );
        address recoveredAddress = ECDSA.recover(digest, _signature);

        require(recoveredAddress == owner(), Errors.InvalidSignature());
        _useNonce(_ref.buyer);
    }
}
