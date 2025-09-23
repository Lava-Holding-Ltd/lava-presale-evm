// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AggregatorV3Interface } from "@chainlink-contracts-0.8.0/src/v0.8/interfaces/AggregatorV3Interface.sol";

import { IOracleAdapter } from "src/interfaces/IOracleAdapter.sol";
import { Constants } from "src/lib/Constants.sol";
import { Errors } from "src/lib/Errors.sol";

/// @title The OracleAdapter SC that manages price feeds for tokens
/// @notice This contract allows the owner to set price feeds for various tokens and retrieve their prices in USD
contract OracleAdapter is IOracleAdapter, Ownable {
    /// @notice The minimum interval in seconds between manual updates in the OracleAdapter SC (e.g., 4200 for 1h10m)
    uint256 public manualUpdateInterval = 4200;

    /// @notice The mapping of token addresses to their corresponding Chainlink price feeds
    /// @dev This mapping is used to get the price of the token in USD, schema: token => Chainlink feed
    mapping(address => address) public priceFeeds;

    /// @notice The mapping of token addresses to their heartbeat threshold in seconds
    /// @dev The heartbeat is used to ensure that the price feed is still active and has been updated recently
    mapping(address => uint256) public heartbeats;

    /// @notice The mapping stores manually pushed prices for a specific token (scaled to 18 decimals)
    /// @dev This allows the owner to set a price for a token that may not have an active price feed
    mapping(address => uint256) public manualPrices;

    /// @notice The timestamp of last manual price update
    /// @dev This is used to enforce a cooldown period between manual updates
    mapping(address => uint256) public manualLastUpdated;

    /// @dev Constructor that initializes the contract with the owner's address
    /// @param _owner The address of the owner who will have permission to set price feeds and manual prices
    constructor(address _owner) Ownable(_owner) { }

    /// @inheritdoc IOracleAdapter
    function setPriceFeeds(address[] calldata tokens, address[] calldata feeds, uint256[] calldata heartbeat)
        external
        onlyOwner
    {
        require(tokens.length == feeds.length && tokens.length == heartbeat.length, Errors.LengthMismatch());
        for (uint256 i; i < tokens.length; i++) {
            address token = tokens[i];

            require(token != address(0) && feeds[i] != address(0), Errors.ZeroAddress());
            require(heartbeat[i] != 0, Errors.ZeroAmount());

            priceFeeds[token] = feeds[i];
            heartbeats[token] = heartbeat[i];
        }

        emit PriceFeedSet(tokens, feeds, heartbeat);
    }

    /// @inheritdoc IOracleAdapter
    function setManualPrice(address token, uint256 price) external onlyOwner {
        require(token != address(0), Errors.ZeroAddress());
        require(price != 0, Errors.ZeroAmount());

        uint256 lastUpdated = manualLastUpdated[token];
        require(block.timestamp >= lastUpdated + manualUpdateInterval, Errors.EarlyManualUpdate());

        manualPrices[token] = price;
        manualLastUpdated[token] = block.timestamp;

        emit ManualPriceUpdated(token, price, block.timestamp);
    }

    /// @inheritdoc IOracleAdapter
    function setManualUpdateInterval(uint256 interval) external onlyOwner {
        require(interval != 0, Errors.ZeroAmount());
        manualUpdateInterval = interval;
        emit ManualUpdateIntervalSet(interval, _msgSender());
    }

    /// @inheritdoc IOracleAdapter
    function getPriceInUSD(address token) external view returns (uint256 price) {
        if (token == Constants.USDC || token == Constants.USDT) return 1 ether;

        address feed = priceFeeds[token];
        if (feed != address(0)) {
            (, int256 answer,, uint256 updatedAt,) = AggregatorV3Interface(feed).latestRoundData();
            require(answer > 0, Errors.ZeroAmount());
            require(block.timestamp - updatedAt <= heartbeats[token], Errors.StalePriceFeed());

            uint8 feedDecimals = AggregatorV3Interface(feed).decimals();
            if (feedDecimals <= 18) price = uint256(answer) * (10 ** (18 - feedDecimals));
            else price = uint256(answer) / (10 ** (feedDecimals - 18));
        } else {
            require(manualPrices[token] != 0, Errors.ZeroAmount());
            require(block.timestamp - manualLastUpdated[token] <= manualUpdateInterval, Errors.StaleManualPrice());
            price = manualPrices[token];
        }
    }
}
