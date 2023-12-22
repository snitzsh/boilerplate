#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-c/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"


#
# TODO:
#   - null
#
# NOTE:
#   - Gets kubeconfig from aws eks.
#
# DESCRIPTION:
#   - null
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
main () {
  utilLooperClusters "get-kubeconfig"
}

main
