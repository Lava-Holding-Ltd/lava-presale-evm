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
  
deploy-oracle:
  forge compile
  forge script script/DeployOracleAdapter.s.sol --rpc-url ethereumSepolia --broadcast --verify -vvv

deploy-salement:
  forge compile
  forge script script/DeployICOSale.s.sol --rpc-url ethereumSepolia --broadcast --verify -vvv