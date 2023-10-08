#!/bin/bash

# TODO:
# - Save in secrets.
export GITHUB_API_TOKEN="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"
# TODO:
# - Save in secrets.
export GITHUB_API_THROTTLE_INTEVAL=30000 # in seconds
# TODO:
# - Save in secrets.
export GITHUB_DOMAIN="https://api.github.com"
# NOTE:
# - Gets the parent directory, ex: ../../../snitzh, not ../../../snitzh/boilerplate
# TODO:
# - Save in secrets.
export SNITZSH_PATH=${PWD%/*}

main () {
  bash "funcs/${1}.sh"
}

main "${1}"
