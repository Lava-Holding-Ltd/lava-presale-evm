default:
  @just --choose

compile:
  forge clean 
  forge compile

test:
  forge clean
  forge test

static-analysis:
  slither . --config-file slither.config.json
  