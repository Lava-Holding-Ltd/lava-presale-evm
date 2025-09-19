// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    uint8 public immutable DECIMALS;

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply, uint8 _decimals)
        ERC20(_name, _symbol)
    {
        DECIMALS = _decimals;
        _mint(_msgSender(), _initialSupply);
    }

    function decimals() public view override returns (uint8) {
        return DECIMALS;
    }

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}
