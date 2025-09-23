# MockERC20
[Git Source](https://github.com/cowchainworkspace/lava-contracts/blob/94fdb9bebf4beec3b3456b7886da7de39447ccbb/src/mock/MockERC20.sol)

**Inherits:**
ERC20


## State Variables
### DECIMALS

```solidity
uint8 public immutable DECIMALS;
```


## Functions
### constructor


```solidity
constructor(string memory _name, string memory _symbol, uint256 _initialSupply, uint8 _decimals)
    ERC20(_name, _symbol);
```

### decimals


```solidity
function decimals() public view override returns (uint8);
```

### mint


```solidity
function mint(address _to, uint256 _amount) external;
```

