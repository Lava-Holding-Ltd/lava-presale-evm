# Constants
[Git Source](https://github.com/cowchainworkspace/lava-contracts/blob/bad4141a2aa5e099145889e50ed8ebad2fa94115/src/lib/Constants.sol)

This library contains constants for the core SCs


## State Variables
### MAX_ROUNDS
*The maximum number of rounds allowed in the ICO sale*


```solidity
uint256 public constant MAX_ROUNDS = 10;
```


### SOFT_CAP_USD
The constant defining the soft cap in USD (normalized to 18 decimals)


```solidity
uint256 public constant SOFT_CAP_USD = 75_000 * 1 ether;
```


### HARD_CAP_USD
The constant defining the hard cap in USD (normalized to 18 decimals)


```solidity
uint256 public constant HARD_CAP_USD = 5_565_000 * 1 ether;
```


### MAX_USD_PER_WALLET
The constant defining the maximum USD amount per wallet (normalized to 18 decimals)


```solidity
uint256 public constant MAX_USD_PER_WALLET = 40_000 * 1 ether;
```


### BASIS_FEE_DIVISOR
*The divisor (10_000 - 100%) to calculate the percentage*


```solidity
uint16 internal constant BASIS_FEE_DIVISOR = 10_000;
```


### _REFERRAL_TYPEHASH
*The typehash for the PurchaseDetails structure used in EIP-712 signatures*


```solidity
bytes32 internal constant _REFERRAL_TYPEHASH = keccak256(
    "PurchaseDetails(bytes32 codeHash,uint8 refType,address buyer,address asset,uint256 amount,uint256 roundId,uint256 nonce,uint256 deadline)"
);
```


### USDC
*The address of the USDC token on Ethereum mainnet*


```solidity
address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
```


### USDT
*The address of the USDT token on Ethereum mainnet*


```solidity
address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
```


### WETH
*The address of the WETH token on Ethereum mainnet*


```solidity
address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
```


