# IICOSale
[Git Source](https://github.com/cowchainworkspace/lava-contracts/blob/bad4141a2aa5e099145889e50ed8ebad2fa94115/src/interfaces/IICOSale.sol)

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

Finalizes the entire sale after all rounds have ended

*Only the owner can call this function. It determines if the sale was successful (i.e., soft cap reached)*


```solidity
function finalizeSale(bool success) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`success`|`bool`|The boolean indicating if the sale was successful (true) or not (false) set by the BE|


### claimRefund

Allows users to claim refunds after an unsuccessful sale

*Users can claim refunds for a specific asset (token) or ETH if the sale was unsuccessful*


```solidity
function claimRefund(address asset) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`asset`|`address`|The address of the asset (token) to claim a refund for, use address(0) for ETH|


### setNewRound

Sets a new sale round with specified parameters


```solidity
function setNewRound(uint256 startTime, uint256 endTime, uint256 tokenPrice, uint256 capTotal, uint256 capPerUser)
    external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`startTime`|`uint256`|The start time of the sale round (timestamp)|
|`endTime`|`uint256`|The end time of the sale round (timestamp)|
|`tokenPrice`|`uint256`|The price of the token in USD, normalized to 18 decimals|
|`capTotal`|`uint256`|The total cap of tokens available for sale in this round|
|`capPerUser`|`uint256`|The maximum number of tokens a single user can purchase in this round|


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
    address indexed owner, address oracle, address indexed treasury, uint256 maxTotalAllocationTokens
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
event SaleFinalized(bool successful, uint256 totalRaised, address indexed admin);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`successful`|`bool`|The boolean indicating if the sale was successful (i.e., soft cap reached)|
|`totalRaised`|`uint256`|The total USD amount raised across all rounds (normalized to 18 decimals)|
|`admin`|`address`|The address of the admin who performed the finalization|

### RefundClaimed
*The event is triggered whenever a user makes the refund claim after the unsuccessful sale*


```solidity
event RefundClaimed(address indexed user, address indexed token, uint256 amount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The address of the user claiming the refund|
|`token`|`address`|The address of the token being refunded, use address(0) for ETH|
|`amount`|`uint256`|The amount of tokens refunded to the user|

### NewRoundSet
*The event is triggered whenever a new sale round is set*


```solidity
event NewRoundSet(
    uint256 roundId, uint256 startTime, uint256 endTime, uint256 tokenPrice, uint256 capTotal, uint256 capPerUser
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`roundId`|`uint256`|The ID of the newly set round|
|`startTime`|`uint256`|The start time of the sale round (timestamp)|
|`endTime`|`uint256`|The end time of the sale round (timestamp)|
|`tokenPrice`|`uint256`|The price of the token in USD, normalized to 18 decimals|
|`capTotal`|`uint256`|The total cap of tokens available for sale in this round|
|`capPerUser`|`uint256`|The maximum number of tokens a single user can purchase in this round|

### Purchased
*The event is triggered whenever a user makes a purchase during an active sale round*


```solidity
event Purchased(
    address indexed user,
    address indexed asset,
    uint256 roundId,
    uint256 assetAmount,
    uint256 usdAmount,
    uint256 tokenAmount,
    uint256 bonusAmount,
    uint256 aggragateTokenAmount
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The address of the user making the purchase|
|`asset`|`address`|The address of the asset (token) used for payment|
|`roundId`|`uint256`|The ID of the sale round during which the purchase was made|
|`assetAmount`|`uint256`|The amount of the asset used for payment|
|`usdAmount`|`uint256`|The USD equivalent amount of the asset used for payment, normalized to 18 decimals|
|`tokenAmount`|`uint256`|The amount of tokens purchased (excluding bonus)|
|`bonusAmount`|`uint256`|The amount of bonus tokens awarded to the user|
|`aggragateTokenAmount`|`uint256`|The total amount of tokens the user has purchased in the current round (including bonus)|

### ReferralApplied
*The event is triggered whenever a referral is applied during a purchase*


```solidity
event ReferralApplied(
    address indexed buyer,
    bytes32 codeHash,
    uint8 refType,
    uint256 roundId,
    uint256 usdValue,
    uint256 baseTokenAmount,
    uint256 bonusTokenAmount
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`buyer`|`address`|The address of the buyer making the purchase|
|`codeHash`|`bytes32`|The hash of the referral code|
|`refType`|`uint8`|The type of referral (e.g., 0 for influencer, 1 for media, etc.)|
|`roundId`|`uint256`|The ID of the sale round during which the purchase was made|
|`usdValue`|`uint256`|The USD equivalent amount of the asset used for payment, normalized to 18 decimals|
|`baseTokenAmount`|`uint256`|The amount of tokens purchased (excluding bonus)|
|`bonusTokenAmount`|`uint256`|The amount of bonus tokens awarded to the buyer|

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
    uint256 capPerUser;
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
|`capPerUser`|`uint256`|The maximum number of tokens a single user can purchase in this round|
|`active`|`bool`|The boolean indicating if the round is active|

### PurchaseDetails
The structure defines the purchase details including referral information


```solidity
struct PurchaseDetails {
    bytes32 codeHash;
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
|`codeHash`|`bytes32`|The hash of the referral code|
|`refType`|`uint8`|The type of referral (e.g., 0 for influencer, 1 for media, etc.)|
|`buyer`|`address`|The address of the buyer making the purchase|
|`asset`|`address`|The address of the asset (token) used for payment|
|`amount`|`uint256`|The amount of the asset used for payment|
|`roundId`|`uint256`|The ID of the sale round|
|`nonce`|`uint256`|The unique nonce to prevent replay attacks|
|`deadline`|`uint256`|The timestamp by which the referral must be used|

