# IOracleAdapter
[Git Source](https://github.com/cowchainworkspace/lava-contracts/blob/12edc468af8ebe3b43e9dc72afaabb19ec99f22a/src/interfaces/IOracleAdapter.sol)

The interface for the OracleAdapter contract that manages price feeds for tokens

*This interface allows the owner to set price feeds and retrieve token prices in USD*


## Functions
### setPriceFeeds

Sets the price feeds for the specific tokens that are used to get their prices in USD


```solidity
function setPriceFeeds(address[] calldata tokens, address[] calldata feeds, uint256[] calldata heartbeat) external;
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
function setManualPrice(address token, uint256 price) external;
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
function setManualUpdateInterval(uint256 interval) external;
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


## Events
### PriceFeedSet
*The event is triggered whenever a price feed is set for a token*


```solidity
event PriceFeedSet(address[] token, address[] feed, uint256[] heartbeat);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address[]`|The array of the token addresses for which the price feed is set|
|`feed`|`address[]`|The array of the Chainlink price feed addresses for the token|
|`heartbeat`|`uint256[]`|The array of the heartbeats threshold in seconds for the price feed|

### ManualPriceUpdated
*The event is triggered whenever a manual price is set for a token*


```solidity
event ManualPriceUpdated(address indexed token, uint256 price, uint256 lastUpdated);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The address of the token for which the manual price is set|
|`price`|`uint256`|The price of the token in USD, scaled to 18 decimals|
|`lastUpdated`|`uint256`|The timestamp of the last manual price update|

### ManualUpdateIntervalSet
*The event is triggered whenever the manual update interval is set*


```solidity
event ManualUpdateIntervalSet(uint256 newInterval, address indexed admin);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newInterval`|`uint256`|The new manual update interval in seconds|
|`admin`|`address`|The address of the admin who performed the update|

