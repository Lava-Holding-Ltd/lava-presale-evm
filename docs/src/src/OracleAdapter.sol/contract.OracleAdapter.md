# OracleAdapter
[Git Source](https://github.com/cowchainworkspace/lava-contracts/blob/94fdb9bebf4beec3b3456b7886da7de39447ccbb/src/OracleAdapter.sol)

**Inherits:**
[IOracleAdapter](/src/interfaces/IOracleAdapter.sol/interface.IOracleAdapter.md), Ownable

This contract allows the owner to set price feeds for various tokens and retrieve their prices in USD


## State Variables
### manualUpdateInterval
The minimum interval in seconds between manual updates in the OracleAdapter SC (e.g., 4200 for 1h10m)


```solidity
uint256 public manualUpdateInterval = 4200;
```


### priceFeeds
The mapping of token addresses to their corresponding Chainlink price feeds

*This mapping is used to get the price of the token in USD, schema: token => Chainlink feed*


```solidity
mapping(address => address) public priceFeeds;
```


### heartbeats
The mapping of token addresses to their heartbeat threshold in seconds

*The heartbeat is used to ensure that the price feed is still active and has been updated recently*


```solidity
mapping(address => uint256) public heartbeats;
```


### manualPrices
The mapping stores manually pushed prices for a specific token (scaled to 18 decimals)

*This allows the owner to set a price for a token that may not have an active price feed*


```solidity
mapping(address => uint256) public manualPrices;
```


### manualLastUpdated
The timestamp of last manual price update

*This is used to enforce a cooldown period between manual updates*


```solidity
mapping(address => uint256) public manualLastUpdated;
```


## Functions
### constructor

*Constructor that initializes the contract with the owner's address*


```solidity
constructor(address _owner) Ownable(_owner);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|The address of the owner who will have permission to set price feeds and manual prices|


### setPriceFeeds

Sets the price feeds for the specific tokens that are used to get their prices in USD


```solidity
function setPriceFeeds(address[] calldata tokens, address[] calldata feeds, uint256[] calldata heartbeat)
    external
    onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokens`|`address[]`|The array of token addresses for which the price feeds are being set|
|`feeds`|`address[]`|The array of Chainlink price feed addresses corresponding to the tokens|
|`heartbeat`|`uint256[]`|The array of heartbeat thresholds in seconds for each price feed|


### setManualPrice

Sets a manual price for a specific token

*This function allows the owner to set a price for a token that may not have an active price feed*


```solidity
function setManualPrice(address token, uint256 price) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The address of the token for which the manual price is being set|
|`price`|`uint256`|The price of the token in USD, scaled to 18 decimals|


### setManualUpdateInterval

Sets the minimum interval between manual price updates for all tokens

*This function allows the owner to set a cooldown period between manual updates*


```solidity
function setManualUpdateInterval(uint256 interval) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interval`|`uint256`|The new manual update interval in seconds|


### getPriceInUSD

Retrieves the price of a specific token in USD using its Chainlink price feed

*This function fetches the latest price from the Chainlink price feed and scales it to 18 decimals*


```solidity
function getPriceInUSD(address token) external view returns (uint256 price);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The address of the token for which the price is being retrieved|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`price`|`uint256`|The price of the token in USD, scaled to 18 decimals|


