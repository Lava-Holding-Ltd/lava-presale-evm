// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

/// @title The ICOSale Interface
/// @notice This interface defines the structures, events and function's prototypes for the ICOSale contract
interface IICOSale {
    /// @notice The structure defines the parameters for each sale round
    /// @param startTime The start time of the sale round (timestamp)
    /// @param endTime The end time of the sale round (timestamp)
    /// @param tokenPrice The price of the token in USD, normalized to 18 decimals
    /// @param capTotal The total cap of tokens available for sale in this round
    /// @param soldTokens The number of tokens sold in this round
    /// @param capPerUser The maximum number of tokens a single user can purchase in this round
    /// @param active The boolean indicating if the round is active
    struct Round {
        uint256 startTime;
        uint256 endTime;
        uint256 tokenPrice;
        uint256 capTotal;
        uint256 soldTokens;
        uint256 capPerUser;
        bool active;
    }

    /// @notice The structure defines the purchase details including referral information
    /// @param codeHash The hash of the referral code
    /// @param refType The type of referral (e.g., 0 for influencer, 1 for media, etc.)
    /// @param buyer The address of the buyer making the purchase
    /// @param asset The address of the asset (token) used for payment
    /// @param amount The amount of the asset used for payment
    /// @param roundId The ID of the sale round
    /// @param nonce The unique nonce to prevent replay attacks
    /// @param deadline The timestamp by which the referral must be used
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

    /// @dev The event is triggered whenever the sale is initialized while SC creation
    /// @param owner The owner of the contract
    /// @param oracle The address of the oracle adapter for price feeds
    /// @param treasury The address where funds will be sent
    /// @param maxTotalAllocationTokens The maximum number of tokens available for sale
    event SaleInitialized(
        address indexed owner, address indexed oracle, address indexed treasury, uint256 maxTotalAllocationTokens
    );

    /// @dev The event is triggered whenever alien funds (leftovers) are rescued from the SC
    /// @param token The address of the token being rescued, use address(0) for ETH
    /// @param recipient The address receiving the rescued funds - usually the treasury
    /// @param amount The amount of tokens rescued
    /// @param admin The address of the admin who performed the rescue
    event FundsRescued(address indexed token, address indexed recipient, uint256 amount, address indexed admin);

    /// @dev The event is triggered whenever a new minimum USD per transaction is set
    /// @param newMinUsdPerTx The new minimum USD amount per transaction
    /// @param admin The address of the admin who performed the update
    event MinUsdPerTxUpdated(uint256 newMinUsdPerTx, address indexed admin);

    /// @dev The event is triggered whenever an asset is approved or disapproved for payment
    /// @param asset The address of the asset (token) that was approved or disapproved
    /// @param approved The boolean indicating whether the asset is approved (true) or not (false)
    /// @param admin The address of the admin who performed the update
    event PayAssetApprovalSet(address indexed asset, bool approved, address indexed admin);

    /// @dev The event is triggered whenever a referral type percentage is updated
    /// @param refType The type of referral being updated
    /// @param percentage The new percentage for the referral type (in basis points, e.g., 100 = 1%)
    /// @param admin The address of the admin who performed the update
    event ReferralTypePercentageUpdated(uint8 refType, uint256 percentage, address indexed admin);

    /// @dev The event is triggered whenever the entire sale is finalized
    /// @param successful The boolean indicating if the sale was successful (i.e., soft cap reached)
    /// @param totalRaised The total USD amount raised across all rounds (normalized to 18 decimals)
    /// @param admin The address of the admin who performed the finalization
    event SaleFinalized(bool successful, uint256 totalRaised, address indexed admin);

    /// @dev The event is triggered whenever a user makes the refund claim after the unsuccessful sale
    /// @param user The address of the user claiming the refund
    /// @param token The address of the token being refunded, use address(0) for ETH
    /// @param amount The amount of tokens refunded to the user
    event RefundClaimed(address indexed user, address indexed token, uint256 amount);

    /// @dev The event is triggered whenever a new sale round is set
    /// @param roundId The ID of the newly set round
    /// @param startTime The start time of the sale round (timestamp)
    /// @param endTime The end time of the sale round (timestamp)
    /// @param tokenPrice The price of the token in USD, normalized to 18 decimals
    /// @param capTotal The total cap of tokens available for sale in this round
    /// @param capPerUser The maximum number of tokens a single user can purchase in this round
    event NewRoundSet(
        uint256 roundId, uint256 startTime, uint256 endTime, uint256 tokenPrice, uint256 capTotal, uint256 capPerUser
    );

    /// @dev The event is triggered whenever a user makes a purchase during an active sale round
    /// @param user The address of the user making the purchase
    /// @param asset The address of the asset (token) used for payment
    /// @param roundId The ID of the sale round during which the purchase was made
    /// @param assetAmount The amount of the asset used for payment
    /// @param usdAmount The USD equivalent amount of the asset used for payment, normalized to 18 decimals
    /// @param tokenAmount The amount of tokens purchased (excluding bonus)
    /// @param bonusAmount The amount of bonus tokens awarded to the user
    /// @param aggregateTokenAmount The total amount of tokens the user has purchased in the current round (including bonus)
    event Purchased(
        address indexed user,
        address indexed asset,
        uint256 roundId,
        uint256 assetAmount,
        uint256 usdAmount,
        uint256 tokenAmount,
        uint256 bonusAmount,
        uint256 aggregateTokenAmount
    );

    /// @dev The event is triggered whenever a referral is applied during a purchase
    /// @param buyer The address of the buyer making the purchase
    /// @param codeHash The hash of the referral code
    /// @param refType The type of referral (e.g., 0 for influencer, 1 for media, etc.)
    /// @param roundId The ID of the sale round during which the purchase was made
    /// @param usdValue The USD equivalent amount of the asset used for payment, normalized to 18 decimals
    /// @param baseTokenAmount The amount of tokens purchased (excluding bonus)
    /// @param bonusTokenAmount The amount of bonus tokens awarded to the buyer
    event ReferralApplied(
        address indexed buyer,
        bytes32 codeHash,
        uint8 refType,
        uint256 roundId,
        uint256 usdValue,
        uint256 baseTokenAmount,
        uint256 bonusTokenAmount
    );

    /// @notice Rescues alien funds (leftovers) from the contract
    /// @dev Only the owner can call this function. It allows rescuing any ERC20 tokens or ETH mistakenly sent to the contract
    /// @param token The address of the token to be rescued, use address(0) for ETH
    /// @param amount The amount of tokens to be rescued
    function rescueFunds(address token, uint256 amount) external;

    /// @notice Sets the minimum USD amount per transaction available for purchase
    /// @param minUsdPerTx The new minimum USD amount per transaction, normalized to 18 decimals
    function setMinUsdPerTx(uint256 minUsdPerTx) external;

    /// @notice Sets or unsets an asset as approved for payment
    /// @param asset The address of the asset (token) to be approved or disapproved, use address(0) for ETH
    /// @param approved The boolean indicating whether the asset is approved (true) or not (false)
    function setApprovedAsset(address asset, bool approved) external;

    /// @notice Sets referral type percentage in basis points (bps)
    /// @param refType The type of referral (e.g., 0 for influencer, 1 for media, etc.)
    /// @param refPercentage The new percentage for the referral type in basis points (e.g., 100 = 1%)
    function setReferralTypeBps(uint8 refType, uint16 refPercentage) external;

    /// @notice Finalizes the entire sale after all rounds have ended
    /// @dev Only the owner can call this function. It determines if the sale was successful (i.e., soft cap reached)
    /// @param success The boolean indicating if the sale was successful (true) or not (false) set by the BE
    function finalizeSale(bool success) external;

    /// @notice Allows users to claim refunds after an unsuccessful sale
    /// @dev Users can claim refunds for a specific asset (token) or ETH if the sale was unsuccessful
    /// @param asset The address of the asset (token) to claim a refund for, use address(0) for ETH
    function claimRefund(address asset) external;

    /// @notice Sets a new sale round with specified parameters
    /// @param startTime The start time of the sale round (timestamp)
    /// @param endTime The end time of the sale round (timestamp)
    /// @param tokenPrice The price of the token in USD, normalized to 18 decimals
    /// @param capTotal The total cap of tokens available for sale in this round
    /// @param capPerUser The maximum number of tokens a single user can purchase in this round
    function setNewRound(uint256 startTime, uint256 endTime, uint256 tokenPrice, uint256 capTotal, uint256 capPerUser)
        external;

    /// @notice Purchases tokens during an active sale round using ETH (exists ability to buy with referral)
    /// @dev The user must send ETH along with the transaction to make a purchase
    /// @param ref The purchase details structure containing referral information
    /// @param sig The EIP-712 signature for the purchase details
    function buyETH(PurchaseDetails calldata ref, bytes calldata sig) external payable;

    /// @notice Purchases tokens during an active sale round using a specified approved ERC20 token (exists ability to buy with referral)
    /// @param ref The purchase details structure containing referral information
    /// @param sig The EIP-712 signature for the purchase details
    function buyToken(PurchaseDetails calldata ref, bytes calldata sig) external;
}
