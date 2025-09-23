// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

/// @title Constants library
/// @notice This library contains constants for the core SCs
library Constants {
    /// @dev The maximum number of rounds allowed in the ICO sale
    uint256 public constant MAX_ROUNDS = 10;

    /// @notice The constant defining the soft cap in USD (normalized to 18 decimals)
    uint256 public constant SOFT_CAP_USD = 75_000 * 1 ether;
    /// @notice The constant defining the hard cap in USD (normalized to 18 decimals)
    uint256 public constant HARD_CAP_USD = 5_565_000 * 1 ether;

    /// @notice The constant defining the maximum USD amount per wallet (normalized to 18 decimals)
    uint256 public constant MAX_USD_PER_WALLET = 50_000 * 1 ether;

    /// @dev The divisor (10_000 - 100%) to calculate the percentage
    uint16 internal constant BASIS_FEE_DIVISOR = 10_000;

    /// @dev The typehash for the PurchaseDetails structure used in EIP-712 signatures
    bytes32 internal constant _REFERRAL_TYPEHASH = keccak256(
        "PurchaseDetails(string refCode,uint8 refType,address buyer,address asset,uint256 amount,uint256 roundId,uint256 nonce,uint256 deadline)"
    );

    /// @dev The address of the USDC token on Ethereum mainnet
    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    /// @dev The address of the USDT token on Ethereum mainnet
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    /// @dev The address of the WETH token on Ethereum mainnet
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
}
