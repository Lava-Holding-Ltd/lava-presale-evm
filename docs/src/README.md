# Solidity Smart Contract Template

This repository provides a template for developing, testing, and deploying Solidity smart contracts using a modern toolchain.

## Features

*   **Modern Tooling**: Leverages Bun, Just, Foundry, Slither, Bulloak, and Soldeer for an efficient development workflow.
*   **Structured Testing**: Uses Bulloak for behavior-driven testing specification and Foundry for execution.
*   **Dependency Management**: Employs Soldeer for Solidity dependency management.
*   **Automation**: Includes a `justfile` for easy access to common development tasks.
*   **Security Focused**: Integrates Slither for static analysis.

## Technologies Used

*   [**Bun**](https://bun.sh/): Fast JavaScript runtime and toolkit (used for package management here).
*   [**Just**](https://github.com/casey/just): A handy command runner.
*   [**Foundry**](https://book.getfoundry.sh/): Blazing fast toolkit for Ethereum application development (Forge for testing/building, Cast for interaction, Anvil for local node).
*   [**Slither**](https://github.com/crytic/slither): Solidity static analysis framework.
*   [**Bulloak**](https://github.com/r1oga/bulloak): Generates Solidity test files from specification files (`.tree`).
*   [**Soldeer**](https://github.com/lazaronixon/soldeer): Minimalist dependency manager for Solidity projects.

## Prerequisites

Before you begin, ensure you have the following installed:

*   [Bun](https://bun.sh/docs/installation)
*   [Foundry](https://book.getfoundry.sh/getting-started/installation)
*   [Just](https://github.com/casey/just#installation)
*   [Soldeer](https://github.com/lazaronixon/soldeer#installation)
*   [Bulloak](https://github.com/r1oga/bulloak#installation)
*   [Slither](https://github.com/crytic/slither#installation)

## Getting Started

1.  **Clone the repository:**
    ```bash
    git clone <your-repo-url>
    cd <your-repo-directory>
    ```
2.  **Install JavaScript dependencies:**
    ```bash
    bun install
    ```
3.  **Install Solidity dependencies:**
    ```bash
    forge soldeer install 
    # or
    soldeer install
    ```

## Project Structure

```
.
├── src/                # Main smart contract source files (.sol)
├── script/             # Deployment scripts (.s.sol)
├── test/               # Test files
│   ├── concrete/       # Bulloak test specifications (.tree) and generated tests (.t.sol)
│   ├── CounterTest.sol # Example Foundry test setup (modify as needed)
│   └── Test.sol        # Base test contract
├── dependencies/       # Solidity dependencies managed by Soldeer
├── bun.lockb           # Bun lockfile
├── foundry.toml        # Foundry configuration
├── justfile            # Just command definitions
├── package.json        # Node.js/Bun project configuration
├── remappings.txt      # Solidity import remappings (often generated)
├── slither.config.json # Slither configuration
├── soldeer.lock        # Soldeer lockfile
└── README.md           # This file
```

## Available Commands (via Just)

Execute these commands from the project root using `just <command>`:

*   `just install-sol`: Install Solidity dependencies using Soldeer.
*   `just build`: Compile the smart contracts using Forge.
*   `just test`: Run the Foundry test suite.
*   `just coverage`: Generate test coverage report.
*   `just gas`: Generate gas usage report.
*   `just lint`: Run Slither static analysis.
*   `just tree`: Generate Solidity test files (`*.t.sol`) from Bulloak specifications (`*.tree`).
*   `just fmt`: Format Solidity code using `forge fmt`.
*   `just clean`: Remove build artifacts.

Check the `justfile` for the exact implementation of these commands.

## Testing with Bulloak

This template uses [Bulloak](https://github.com/r1oga/bulloak) to define test cases in a human-readable format (`.tree` files) located in `test/concrete/`.

1.  Write your test specifications in `.tree` files within subdirectories under `test/concrete/` (e.g., `test/concrete/myfeature/MyContract.myFunction.tree`).
2.  Run `just tree` or `bunx bulloak`.
3.  This command reads the `.tree` files and generates corresponding Solidity test files (`.t.sol`) in the same directories.
4.  Implement the test logic within the generated `it(...) { ... }` blocks in the `.t.sol` files.
5.  Run `just test` to execute the tests using Foundry.

## Foundry Basics

(Retain essential Foundry commands if needed, or refer to official docs)

*   **Build:** `forge build`
*   **Test:** `forge test`
*   **Format:** `forge fmt`
*   **Local Node:** `anvil`
*   **Deploy Script:** `forge script script/YourScript.s.sol --rpc-url <rpc> --private-key <pk>`
*   **Interact:** `cast <subcommand>`

Refer to the [Foundry Book](https://book.getfoundry.sh/) for detailed documentation.

## Contributing

Contributions are welcome! Please follow standard Git practices (fork, branch, pull request).

## License

(Specify your license, e.g., MIT, UNLICENSED)
