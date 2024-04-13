#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-g/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - Support arguments
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Clone dependencies to lower environment.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function main () {
  gClustersFileCreateLowerRegionEnvironment
}

main
