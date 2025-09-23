# Lava Smart Contracts | ICO Sale

A secure and efficient ICO smart contract system with price oracle integration. This project implements a flexible ICO sale mechanism with multiple rounds, referral system, and Chainlink price feed integration.

## Features

- **Multi-Round ICO**: Supports multiple sale rounds with different pricing and allocation strategies
- **Oracle Integration**: Utilizes Chainlink price feeds for real-time price data with fallback to manual pricing
- **Referral System**: Built-in referral program with different tiers (Influencer, Media)
- **Security**: Implements reentrancy protection, access control, and input validation. Purchase is available with a signature usage.
- **Gas Optimization**: Efficient storage usage and batch operations where applicable

## Contracts Overview

### 1. ICOSale

The main ICO contract that handles token sales, referrals, and fund management.

Key Functions:
- `buyToken`: Purchase tokens using supported ERC20 tokens
- `buyETH`: Purchase tokens using native ETH
- `finalizeSale`: Finalize the ICO and distribute funds
- `rescueFunds`: Emergency function to recover funds
- `setNewRound`: Configure new sale rounds
- `setMinUsdPerTx`: Set the minimum USD amount per transaction
- `setApprovedAsset`: Set the approved assets for the ICO
- `setReferralTypeBps`: Set the referral bonus percentage for a specific referral type

### 2. OracleAdapter

Manages price feeds for different tokens and provides price data to the ICO contract.

Key Functions:
- `setPriceFeeds`: Configure Chainlink price feeds for tokens
- `setManualPrice`: Set manual prices as fallback
- `getPrice`: Get the current price of a token in USD

## Prerequisites

- Node.js (v16+)
- Foundry
- Access to an Ethereum node (e.g., Infura, Alchemy)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/lava-contracts.git
   cd lava-contracts
   ```

2. Install dependencies:
   ```bash
   forge soldeer install
   ```

## Configuration

1. Create a `.env` file in the root directory with the following variables:
   ```
   PRIVATE_KEY=your_private_key
   INFURA_API_KEY=your_infura_api_key
   ETHERSCAN_API_KEY=your_etherscan_api_key
   ```

2. Update the deployment scripts in `script/` with your contract parameters.

## Deployment

### Mainnet/Testnet Deployment

1. Compile the contracts:
   ```bash
   forge build
   ```

2. Deploy the OracleAdapter first:
   ```bash
   forge script script/DeployOracleAdapter.s.sol --rpc-url <network> --private-key <pk>
   ```

3. Deploy the ICOSale contract:
   ```bash
   forge script script/DeployICOSale.s.sol --rpc-url <network> --private-key <pk>
   ```

## Testing

Run the test suite:

```bash
forge test
```

## Security Considerations

- Perform thorough testing on testnets before mainnet deployment
- Review and set appropriate access controls and timelocks

