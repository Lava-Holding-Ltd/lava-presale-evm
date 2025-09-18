// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

/// @title Errors Library
/// @notice This library contains custom error definitions for the core SCs
library Errors {
    /// @dev The custom error for zero address inputs
    error ZeroAddress();
    /// @dev The custom error for input zero amount deposits/withdrawals or position params
    error ZeroAmount();
    /// @dev The custom error for cases when no refund is due
    error NoRefund();
    /// @dev The custom error for minimum amount violations
    error UnderMin();
    /// @dev The custom error for maximum amount violations - e.g. cap reached
    error CapReached();
    /// @dev The custom error for maximum amount violations - e.g. max allocation exceeded
    error HardCapExceeded();
    /// @dev The custom error for maximum wallet cap violations - e.g. max allocation per wallet exceeded
    error WalletCapExceeded();
    /// @dev The custom error for insufficient balance cases
    error InsufficientBalance();
    /// @dev The custom error for different lengths of arrays when they are expected to be the same
    error LengthMismatch();
    /// @dev The custom error for cases when the boolean indicator already set to expected value
    error IndicatorAlreadySet();
    /// @dev The custom error for early manual price updates
    error EarlyManualUpdate();
    /// @dev The custom error for stale manual price updates
    error StaleManualPrice();
    /// @dev The custom error for stale price feed updates
    error StalePriceFeed();
    /// @dev The custom error for incorrect timeframe inputs
    error InvalidTimeframe();
    /// @dev The custom error for invalid buyer bonus inputs
    error InvalidBuyerBonus();
    /// @dev The custom error for cases when the current round is active y
    error ActiveRoundExists();
    /// @dev The custom error for cases when the current round is not active
    error InactiveRound();
    /// @dev The custom error for cases when the provided asset is not accepted for payment
    error NotAcceptedAsset();
    /// @dev The custom error for cases when the sale has not already been finalized
    error SaleNotFinished();
    /// @dev The custom error for cases when the sale was successful (i.e., soft cap reached)
    error SaleSuccessful();
    /// @dev The custom error for cases when the sale has already been finalized
    error SaleAlreadyFinalized();
    /// @dev The custom error for cases when price change is attempted without pausing the round
    error PriceChangeRequiresPause();
    /// @dev The custom error for cases when the provided referral type is invalid
    error InvalidReferralType();
    /// @dev The custom error for cases when the provided referral percentage is invalid
    error InvalidReferralPercentage();
    /// @dev The custom error for cases when the signature's deadline has expired
    error ExpiredSignature();
    /// @dev The custom error for cases when the signature is invalid
    error InvalidSignature();
    /// @dev The custom error for cases when the nonce does not match the expected value
    error NonceMismatch();
    /// @dev The custom error for cases when the buyer address does not match the caller's address
    error NotBuyer();
}
