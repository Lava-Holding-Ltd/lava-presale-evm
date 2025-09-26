# ICOSale
[Git Source](https://github.com/cowchainworkspace/lava-contracts/blob/12edc468af8ebe3b43e9dc72afaabb19ec99f22a/src/ICOSale.sol)

**Inherits:**
[IICOSale](/src/interfaces/IICOSale.sol/interface.IICOSale.md), EIP712, Ownable, ReentrancyGuard, Nonces

This contract manages the ICO sale process, including rounds, purchases, referrals, and refunds

*The contract uses OpenZeppelin libraries for security and standard functionalities*


## State Variables
### TREASURY_WALLET
The treasury address where funds will be sent


```solidity
address public immutable TREASURY_WALLET;
```


### ORACLE_ADAPTER
The oracle adapter for fetching price feeds


```solidity
IOracleAdapter public immutable ORACLE_ADAPTER;
```


### MAX_TOTAL_ALLOCATION_TOKENS
The maximum number of tokens available for sale


```solidity
uint256 public immutable MAX_TOTAL_ALLOCATION_TOKENS;
```


### minUsdPerTx
The minimum USD amount per transaction available for purchase


```solidity
uint256 public minUsdPerTx;
```


### totalUsdRaised
The total USD amount raised across all rounds (normalized to 18 decimals)


```solidity
uint256 public totalUsdRaised;
```


### totalAllocatedTokens
The total number of tokens allocated across all buyers and rounds

*This value cannot exceed MAX_TOTAL_ALLOCATION_TOKENS*


```solidity
uint256 public totalAllocatedTokens;
```


### currentRoundId
The current round ID


```solidity
uint256 public currentRoundId;
```


### saleFinalized
The boolean indicating if the sale has been finalized

*Once finalized, no more deposits are allowed*


```solidity
bool public saleFinalized;
```


### rounds
The mapping keeps details of each sale round

*The general sale parameters are defined in the Round struct, schema: roundId => Round*


```solidity
mapping(uint256 => Round) public rounds;
```


### isApprovedAsset
The mapping tracks the approved assets for payment

*The key is the token address, and the value indicates if it's approved (true) or not (false)*


```solidity
mapping(address => bool) public isApprovedAsset;
```


### walletUsdRaised
The mapping tracks the total USD amount raised per wallet (normalized to 18 decimals)


```solidity
mapping(address => uint256) public walletUsdRaised;
```


### totalBuyerAllocation
The mapping tracks the allocation per user across all rounds

*The schema is: user address => total allocated tokens*


```solidity
mapping(address => uint256) public totalBuyerAllocation;
```


### roundBuyerAllocation
The mapping tracks the round-specific allocation per user

*The schema is: round ID => user address => allocated tokens in that round*


```solidity
mapping(uint256 => mapping(address => uint256)) public roundBuyerAllocation;
```


### refundable
The mapping tracks refundable amounts per user and asset

*The schema is: user address => token address => refundable amount*


```solidity
mapping(address => mapping(address => uint256)) public refundable;
```


### referralBonusBpsByType
The mapping tracks referral bonus basis points by referral type

*The key is the referral type (e.g., 0 for influencer, 1 for media, etc.), and the value is the bonus in basis points*


```solidity
mapping(uint8 => uint16) public referralBonusBpsByType;
```


### refTotalUsd
The mapping tracks total USD raised per referral code (normalized to 18 decimals)

*The key is the string of the referral code*


```solidity
mapping(string => uint256) public refTotalUsd;
```


### refTotalBonusTokens
The mapping tracks total bonus tokens awarded per referral code

*The key is the string of the referral code*


```solidity
mapping(string => uint256) public refTotalBonusTokens;
```


## Functions
### receive

Fallback function to receive Ether


```solidity
receive() external payable;
```

### constructor

*The constructor initializes the contract with essential parameters*


```solidity
constructor(address _owner, address _oracle, address _treasury, uint256 _maxTotalAllocationTokens)
    Ownable(_owner)
    EIP712("ICOSale", "1");
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|The owner of the contract|
|`_oracle`|`address`|The address of the oracle adapter for price feeds|
|`_treasury`|`address`|The address where funds will be sent|
|`_maxTotalAllocationTokens`|`uint256`|The maximum number of tokens available for sale|


### rescueFunds

Rescues alien funds (leftovers) from the contract

*Only the owner can call this function. It allows rescuing any ERC20 tokens or ETH mistakenly sent to the contract*


```solidity
function rescueFunds(address _token, uint256 _amount) external nonReentrant onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`||
|`_amount`|`uint256`||


### setMinUsdPerTx

Sets the minimum USD amount per transaction available for purchase


```solidity
function setMinUsdPerTx(uint256 _minUsdPerTx) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_minUsdPerTx`|`uint256`||


### setApprovedAsset

Sets or unsets an asset as approved for payment


```solidity
function setApprovedAsset(address _asset, bool _approved) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_asset`|`address`||
|`_approved`|`bool`||


### setReferralTypeBps

Sets referral type percentage in basis points (bps)


```solidity
function setReferralTypeBps(uint8 _refType, uint16 _refPercentage) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_refType`|`uint8`||
|`_refPercentage`|`uint16`||


### finalizeSale

Finalizes the entire sale after all rounds have ended. Only the owner can call this function


```solidity
function finalizeSale() external onlyOwner;
```

### setNewRound

Sets a new sale round with specified parameters


```solidity
function setNewRound(uint256 _startTime, uint256 _endTime, uint256 _tokenPrice, uint256 _capTotal) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_startTime`|`uint256`||
|`_endTime`|`uint256`||
|`_tokenPrice`|`uint256`||
|`_capTotal`|`uint256`||


### buyETH

Purchases tokens during an active sale round using ETH (exists ability to buy with referral)

*The user must send ETH along with the transaction to make a purchase*


```solidity
function buyETH(PurchaseDetails calldata _ref, bytes calldata _sig, string calldata _refCodeString)
    external
    payable
    nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ref`|`PurchaseDetails`||
|`_sig`|`bytes`||
|`_refCodeString`|`string`||


### buyToken

Purchases tokens during an active sale round using a specified approved ERC20 token (exists ability to buy with referral)


```solidity
function buyToken(PurchaseDetails calldata _ref, bytes calldata _sig, string calldata _refCodeString)
    external
    nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ref`|`PurchaseDetails`||
|`_sig`|`bytes`||
|`_refCodeString`|`string`||


### _buyChecksAndEffects

*Internal function to handle purchase checks and state updates*


```solidity
function _buyChecksAndEffects(
    address _payAsset,
    uint256 _payAmount,
    address _buyer,
    string calldata _refCode,
    uint8 _refType
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_payAsset`|`address`|The address of the asset used for payment|
|`_payAmount`|`uint256`|The amount of the asset used for payment|
|`_buyer`|`address`|The address of the buyer|
|`_refCode`|`string`|The referral code used (if any)|
|`_refType`|`uint8`|The type of referral (if any)|


### _verifyReferralSignature

*Internal function to verify the referral signature and update the nonce*


```solidity
function _verifyReferralSignature(PurchaseDetails calldata _ref, bytes calldata _signature) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ref`|`PurchaseDetails`|The referral details structure|
|`_signature`|`bytes`|The EIP-712 signature to verify|


## Enums
### RefType
The enum defining the referral types used for categorizing referrals


```solidity
enum RefType {
    NoReferral,
    Influencer,
    Media
}
```

