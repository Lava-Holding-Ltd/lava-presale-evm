set dotenv-load := true

default:
  @just --choose

compile:
  forge clean 
  forge compile

test:
  forge clean
  forge test -vvv

static-analysis:
  slither . --config-file slither.config.json
  
# Добавить кошелек в cast wallet из приватного ключа
wallet-add name private_key:
  cast wallet import {{name}} --private-key {{private_key}}
  
# Деплой OracleAdapter (использует --account <wallet> или $DEPLOYER_PRIVATE_KEY)
deploy-oracle wallet="" rpc="ethereum":
  #!/usr/bin/env bash
  forge compile
  if [ -n "{{wallet}}" ]; then
    forge script script/DeployOracleAdapter.s.sol --rpc-url {{rpc}} --broadcast --verify --account {{wallet}} -vvv
  elif [ -n "$DEPLOYER_PRIVATE_KEY" ]; then
    forge script script/DeployOracleAdapter.s.sol --rpc-url {{rpc}} --broadcast --verify --private-key "$DEPLOYER_PRIVATE_KEY" -vvv
  else
    echo "Error: provide wallet=<cast_name> or set DEPLOYER_PRIVATE_KEY in env/.env" >&2
    exit 1
  fi

# Деплой ICOSale (использует --account <wallet> или $DEPLOYER_PRIVATE_KEY)
deploy-salement wallet="" rpc="ethereum":
  #!/usr/bin/env bash
  forge compile
  if [ -n "{{wallet}}" ]; then
    forge script script/DeployICOSale.s.sol --rpc-url {{rpc}} --broadcast --verify --account {{wallet}} -vvv
  elif [ -n "$DEPLOYER_PRIVATE_KEY" ]; then
    forge script script/DeployICOSale.s.sol --rpc-url {{rpc}} --broadcast --verify --private-key "$DEPLOYER_PRIVATE_KEY" -vvv
  else
    echo "Error: provide wallet=<cast_name> or set DEPLOYER_PRIVATE_KEY in env/.env" >&2
    exit 1
  fi

# Передача ownership контрактов (использует --account <wallet> или $DEPLOYER_PRIVATE_KEY)
transfer-ownership wallet="" rpc="ethereum":
  #!/usr/bin/env bash
  forge compile
  if [ -n "{{wallet}}" ]; then
    forge script script/TransferOwnership.s.sol --rpc-url {{rpc}} --broadcast --account {{wallet}} -vvv
  elif [ -n "$DEPLOYER_PRIVATE_KEY" ]; then
    forge script script/TransferOwnership.s.sol --rpc-url {{rpc}} --broadcast --private-key "$DEPLOYER_PRIVATE_KEY" -vvv
  else
    echo "Error: provide wallet=<cast_name> or set DEPLOYER_PRIVATE_KEY in env/.env" >&2
    exit 1
  fi