# Utils
[Git Source](https://github.com/cowchainworkspace/lava-contracts/blob/94fdb9bebf4beec3b3456b7886da7de39447ccbb/src/lib/Utils.sol)

The Utils library provides utility functions for normalizing amounts to different decimal places

*It includes functions to normalize amounts to 18 decimals and to convert from 18 decimals to 6 decimals*


## Functions
### _normalizeTo18Decimals

*Returns the normalized amount to 18 decimals*


```solidity
function _normalizeTo18Decimals(address asset, uint256 amount) internal view returns (uint256 normalizedAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`asset`|`address`|The address of the asset (token)|
|`amount`|`uint256`|The amount to normalize|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`normalizedAmount`|`uint256`|The normalized amount in 18 decimals|


### _convertDecimals

*Converts an `amount` from one decimal‐precision to another*


```solidity
function _convertDecimals(uint256 amount, uint8 fromDecimals, uint8 toDecimals)
    private
    pure
    returns (uint256 converted);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|The raw amount in `fromDecimals` precision|
|`fromDecimals`|`uint8`|The number of decimals in `amount`|
|`toDecimals`|`uint8`|The target number of decimals|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`converted`|`uint256`|The same input value, expressed in `toDecimals` precision|


