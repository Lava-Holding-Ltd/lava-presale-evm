# IICOSale
[Git Source](https://github.com/cowchainworkspace/lava-contracts/blob/94fdb9bebf4beec3b3456b7886da7de39447ccbb/src/interfaces/IICOSale.sol)

This interface defines the structures, events and function's prototypes for the ICOSale contract


## Functions
### rescueFunds

Rescues alien funds (leftovers) from the contract

*Only the owner can call this function. It allows rescuing any ERC20 tokens or ETH mistakenly sent to the contract*


```solidity
function rescueFunds(address token, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The address of the token to be rescued, use address(0) for ETH|
|`amount`|`uint256`|The amount of tokens to be rescued|


### setMinUsdPerTx

Sets the minimum USD amount per transaction available for purchase


```solidity
function setMinUsdPerTx(uint256 minUsdPerTx) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`minUsdPerTx`|`uint256`|The new minimum USD amount per transaction, normalized to 18 decimals|


### setApprovedAsset

Sets or unsets an asset as approved for payment


```solidity
function setApprovedAsset(address asset, bool approved) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`asset`|`address`|The address of the asset (token) to be approved or disapproved, use address(0) for ETH|
|`approved`|`bool`|The boolean indicating whether the asset is approved (true) or not (false)|


### setReferralTypeBps

Sets referral type percentage in basis points (bps)


```solidity
function setReferralTypeBps(uint8 refType, uint16 refPercentage) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`refType`|`uint8`|The type of referral (e.g., 0 for influencer, 1 for media, etc.)|
|`refPercentage`|`uint16`|The new percentage for the referral type in basis points (e.g., 100 = 1%)|


### finalizeSale

Finalizes the entire sale after all rounds have ended. Only the owner can call this function


```solidity
function finalizeSale() external;
```

### setNewRound

Sets a new sale round with specified parameters


```solidity
function setNewRound(uint256 startTime, uint256 endTime, uint256 tokenPrice, uint256 capTotal) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`startTime`|`uint256`|The start time of the sale round (timestamp)|
|`endTime`|`uint256`|The end time of the sale round (timestamp)|
|`tokenPrice`|`uint256`|The price of the token in USD, normalized to 18 decimals|
|`capTotal`|`uint256`|The total cap of tokens available for sale in this round|


### buyETH

Purchases tokens during an active sale round using ETH (exists ability to buy with referral)

*The user must send ETH along with the transaction to make a purchase*


```solidity
function buyETH(PurchaseDetails calldata ref, bytes calldata sig) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ref`|`PurchaseDetails`|The purchase details structure containing referral information|
|`sig`|`bytes`|The EIP-712 signature for the purchase details|


### buyToken

Purchases tokens during an active sale round using a specified approved ERC20 token (exists ability to buy with referral)


```solidity
function buyToken(PurchaseDetails calldata ref, bytes calldata sig) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ref`|`PurchaseDetails`|The purchase details structure containing referral information|
|`sig`|`bytes`|The EIP-712 signature for the purchase details|


## Events
### SaleInitialized
*The event is triggered whenever the sale is initialized while SC creation*


```solidity
event SaleInitialized(
    address indexed owner, address indexed oracle, address indexed treasury, uint256 maxTotalAllocationTokens
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|The owner of the contract|
|`oracle`|`address`|The address of the oracle adapter for price feeds|
|`treasury`|`address`|The address where funds will be sent|
|`maxTotalAllocationTokens`|`uint256`|The maximum number of tokens available for sale|

### FundsRescued
*The event is triggered whenever alien funds (leftovers) are rescued from the SC*


```solidity
event FundsRescued(address indexed token, address indexed recipient, uint256 amount, address indexed admin);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The address of the token being rescued, use address(0) for ETH|
|`recipient`|`address`|The address receiving the rescued funds - usually the treasury|
|`amount`|`uint256`|The amount of tokens rescued|
|`admin`|`address`|The address of the admin who performed the rescue|

### MinUsdPerTxUpdated
*The event is triggered whenever a new minimum USD per transaction is set*


```solidity
event MinUsdPerTxUpdated(uint256 newMinUsdPerTx, address indexed admin);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newMinUsdPerTx`|`uint256`|The new minimum USD amount per transaction|
|`admin`|`address`|The address of the admin who performed the update|

### PayAssetApprovalSet
*The event is triggered whenever an asset is approved or disapproved for payment*


```solidity
event PayAssetApprovalSet(address indexed asset, bool approved, address indexed admin);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`asset`|`address`|The address of the asset (token) that was approved or disapproved|
|`approved`|`bool`|The boolean indicating whether the asset is approved (true) or not (false)|
|`admin`|`address`|The address of the admin who performed the update|

### ReferralTypePercentageUpdated
*The event is triggered whenever a referral type percentage is updated*


```solidity
event ReferralTypePercentageUpdated(uint8 refType, uint256 percentage, address indexed admin);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`refType`|`uint8`|The type of referral being updated|
|`percentage`|`uint256`|The new percentage for the referral type (in basis points, e.g., 100 = 1%)|
|`admin`|`address`|The address of the admin who performed the update|

### SaleFinalized
*The event is triggered whenever the entire sale is finalized*


```solidity
event SaleFinalized(uint256 totalRaised, address indexed admin);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`totalRaised`|`uint256`|The total USD amount raised across all rounds (normalized to 18 decimals)|
|`admin`|`address`|The address of the admin who performed the finalization|

### NewRoundSet
*The event is triggered whenever a new sale round is set*


```solidity
event NewRoundSet(uint256 roundId, uint256 startTime, uint256 endTime, uint256 tokenPrice, uint256 capTotal);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`roundId`|`uint256`|The ID of the newly set round|
|`startTime`|`uint256`|The start time of the sale round (timestamp)|
|`endTime`|`uint256`|The end time of the sale round (timestamp)|
|`tokenPrice`|`uint256`|The price of the token in USD, normalized to 18 decimals|
|`capTotal`|`uint256`|The total cap of tokens available for sale in this round|

### Purchased
*The event is triggered whenever a purchase is made during an active sale round*


```solidity
event Purchased(
    uint256 roundId,
    address indexed buyer,
    string refCode,
    uint8 refType,
    address indexed asset,
    uint256 amount,
    uint256 usdValue,
    uint256 tokensBought,
    uint256 refBonusTokens,
    uint256 totalTokens
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`roundId`|`uint256`|The ID of the sale round during which the purchase was made|
|`buyer`|`address`|The address of the buyer who made the purchase|
|`refCode`|`string`|The referral code used for the purchase (if any)|
|`refType`|`uint8`|The type of referral used (e.g., 0 for no referral, 1 for influencer, etc.)|
|`asset`|`address`|The address of the asset (token) used for payment|
|`amount`|`uint256`|The amount of the asset used for payment|
|`usdValue`|`uint256`|The USD value of the purchase (normalized to 18 decimals)|
|`tokensBought`|`uint256`|The number of tokens bought in the purchase|
|`refBonusTokens`|`uint256`|The number of bonus tokens awarded due to referral (if any)|
|`totalTokens`|`uint256`|The total number of tokens allocated to the buyer (including bonus tokens)|

## Structs
### Round
The structure defines the parameters for each sale round


```solidity
struct Round {
    uint256 startTime;
    uint256 endTime;
    uint256 tokenPrice;
    uint256 capTotal;
    uint256 soldTokens;
    bool active;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`startTime`|`uint256`|The start time of the sale round (timestamp)|
|`endTime`|`uint256`|The end time of the sale round (timestamp)|
|`tokenPrice`|`uint256`|The price of the token in USD, normalized to 18 decimals|
|`capTotal`|`uint256`|The total cap of tokens available for sale in this round|
|`soldTokens`|`uint256`|The number of tokens sold in this round|
|`active`|`bool`|The boolean indicating if the round is active|

### PurchaseDetails
The structure defines the purchase details including referral information


```solidity
struct PurchaseDetails {
    string refCode;
    uint8 refType;
    address buyer;
    address asset;
    uint256 amount;
    uint256 roundId;
    uint256 nonce;
    uint256 deadline;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`refCode`|`string`|The referral code used for the purchase (if any)|
|`refType`|`uint8`|The type of referral (e.g., 0 for influencer, 1 for media, etc.)|
|`buyer`|`address`|The address of the buyer making the purchase|
|`asset`|`address`|The address of the asset (token) used for payment|
|`amount`|`uint256`|The amount of the asset used for payment|
|`roundId`|`uint256`|The ID of the sale round|
|`nonce`|`uint256`|The unique nonce to prevent replay attacks|
|`deadline`|`uint256`|The timestamp by which the referral must be used|

