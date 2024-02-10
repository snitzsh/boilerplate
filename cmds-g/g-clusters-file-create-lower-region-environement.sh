#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-r/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - This command should clone the higher environment like this
#     dev -> clone dependencies -> sit
#     sit -> clone dependencies -> uat
#     ...
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
gClustersFileCreateLowerRegionEnvironment () {
  echo ""
}
