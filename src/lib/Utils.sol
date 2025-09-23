// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @notice The Utils library provides utility functions for normalizing amounts to different decimal places
/// @dev It includes functions to normalize amounts to 18 decimals and to convert from 18 decimals to 6 decimals
library Utils {
    /// @dev Returns the normalized amount to 18 decimals
    /// @param asset The address of the asset (token)
    /// @param amount The amount to normalize
    /// @return normalizedAmount The normalized amount in 18 decimals
    function _normalizeTo18Decimals(address asset, uint256 amount) internal view returns (uint256 normalizedAmount) {
        uint8 fromDecimals = IERC20Metadata(asset).decimals();
        normalizedAmount = _convertDecimals(amount, fromDecimals, 18);
    }

    /// @dev Converts an `amount` from one decimal‐precision to another
    /// @param amount The raw amount in `fromDecimals` precision
    /// @param fromDecimals The number of decimals in `amount`
    /// @param toDecimals The target number of decimals
    /// @return converted The same input value, expressed in `toDecimals` precision
    function _convertDecimals(uint256 amount, uint8 fromDecimals, uint8 toDecimals)
        private
        pure
        returns (uint256 converted)
    {
        if (fromDecimals == toDecimals) {
            return amount;
        } else if (fromDecimals < toDecimals) {
            unchecked {
                return amount * (10 ** (toDecimals - fromDecimals));
            }
        } else {
            unchecked {
                return amount / (10 ** (fromDecimals - toDecimals));
            }
        }
    }
}
