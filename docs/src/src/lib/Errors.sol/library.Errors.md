# Errors
[Git Source](https://github.com/cowchainworkspace/lava-contracts/blob/12edc468af8ebe3b43e9dc72afaabb19ec99f22a/src/lib/Errors.sol)

This library contains custom error definitions for the core SCs


## Errors
### ZeroAddress
*The custom error for zero address inputs*


```solidity
error ZeroAddress();
```

### ZeroAmount
*The custom error for input zero amount re purchase params*


```solidity
error ZeroAmount();
```

### UnderMin
*The custom error for minimum amount violations*


```solidity
error UnderMin();
```

### CapReached
*The custom error for maximum amount violations - e.g. cap reached*


```solidity
error CapReached();
```

### HardCapExceeded
*The custom error for maximum amount violations - e.g. max allocation exceeded*


```solidity
error HardCapExceeded();
```

### WalletCapExceeded
*The custom error for maximum wallet cap violations - e.g. max allocation per wallet exceeded*


```solidity
error WalletCapExceeded();
```

### InsufficientBalance
*The custom error for insufficient balance cases*


```solidity
error InsufficientBalance();
```

### LengthMismatch
*The custom error for different lengths of arrays when they are expected to be the same*


```solidity
error LengthMismatch();
```

### IndicatorAlreadySet
*The custom error for cases when the boolean indicator already set to expected value*


```solidity
error IndicatorAlreadySet();
```

### EarlyManualUpdate
*The custom error for early manual price updates*


```solidity
error EarlyManualUpdate();
```

### StaleManualPrice
*The custom error for stale manual price updates*


```solidity
error StaleManualPrice();
```

### StalePriceFeed
*The custom error for stale price feed updates*


```solidity
error StalePriceFeed();
```

### InvalidTimeframe
*The custom error for incorrect timeframe inputs*


```solidity
error InvalidTimeframe();
```

### InvalidBuyerBonus
*The custom error for invalid buyer bonus inputs*


```solidity
error InvalidBuyerBonus();
```

### ActiveRoundExists
*The custom error for cases when the current round is active*


```solidity
error ActiveRoundExists();
```

### InactiveRound
*The custom error for cases when the current round is not active*


```solidity
error InactiveRound();
```

### NotAcceptedAsset
*The custom error for cases when the provided asset is not accepted for payment*


```solidity
error NotAcceptedAsset();
```

### SaleNotFinished
*The custom error for cases when the sale has not already been finalized*


```solidity
error SaleNotFinished();
```

### SaleAlreadyFinalized
*The custom error for cases when the sale has already been finalized*


```solidity
error SaleAlreadyFinalized();
```

### InvalidReferralType
*The custom error for cases when the provided referral type is invalid*


```solidity
error InvalidReferralType();
```

### InvalidReferralPercentage
*The custom error for cases when the provided referral percentage is invalid*


```solidity
error InvalidReferralPercentage();
```

### ExpiredSignature
*The custom error for cases when the signature's deadline has expired*


```solidity
error ExpiredSignature();
```

### InvalidSignature
*The custom error for cases when the signature is invalid*


```solidity
error InvalidSignature();
```

### NonceMismatch
*The custom error for cases when the nonce does not match the expected value*


```solidity
error NonceMismatch();
```

### NotBuyer
*The custom error for cases when the buyer address does not match the caller's address*


```solidity
error NotBuyer();
```

