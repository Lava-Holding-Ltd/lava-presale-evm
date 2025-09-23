// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

/// @title The IOracleAdapter interface
/// @notice The interface for the OracleAdapter contract that manages price feeds for tokens
/// @dev This interface allows the owner to set price feeds and retrieve token prices in USD
interface IOracleAdapter {
    /// @dev The event is triggered whenever a price feed is set for a token
    /// @param token The array of the token addresses for which the price feed is set
    /// @param feed The array of the Chainlink price feed addresses for the token
    /// @param heartbeat The array of the heartbeats threshold in seconds for the price feed
    event PriceFeedSet(address[] token, address[] feed, uint256[] heartbeat);

    /// @dev The event is triggered whenever a manual price is set for a token
    /// @param token The address of the token for which the manual price is set
    /// @param price The price of the token in USD, scaled to 18 decimals
    /// @param lastUpdated The timestamp of the last manual price update
    event ManualPriceUpdated(address indexed token, uint256 price, uint256 lastUpdated);

    /// @dev The event is triggered whenever the manual update interval is set
    /// @param newInterval The new manual update interval in seconds
    /// @param admin The address of the admin who performed the update
    event ManualUpdateIntervalSet(uint256 newInterval, address indexed admin);

    /// @notice Sets the price feeds for the specific tokens that are used to get their prices in USD
    /// @param tokens The array of token addresses for which the price feeds are being set
    /// @param feeds The array of Chainlink price feed addresses corresponding to the tokens
    /// @param heartbeat The array of heartbeat thresholds in seconds for each price feed
    function setPriceFeeds(address[] calldata tokens, address[] calldata feeds, uint256[] calldata heartbeat)
        external;

    /// @notice Sets a manual price for a specific token
    /// @dev This function allows the owner to set a price for a token that may not have an active price feed
    /// @param token The address of the token for which the manual price is being set
    /// @param price The price of the token in USD, scaled to 18 decimals
    function setManualPrice(address token, uint256 price) external;

    /// @notice Sets the minimum interval between manual price updates for all tokens
    /// @dev This function allows the owner to set a cooldown period between manual updates
    /// @param interval The new manual update interval in seconds
    function setManualUpdateInterval(uint256 interval) external;

    /// @notice Retrieves the price of a specific token in USD using its Chainlink price feed
    /// @dev This function fetches the latest price from the Chainlink price feed and scales it to 18 decimals
    /// @param token The address of the token for which the price is being retrieved
    /// @return price The price of the token in USD, scaled to 18 decimals
    function getPriceInUSD(address token) external view returns (uint256 price);
}
