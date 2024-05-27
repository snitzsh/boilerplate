#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-r/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - null
#
# NOTE:
#   - null
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
function main () {
  local -ar args=("$@")
  utilLooperRRepositories "${args[@]}"
}

#
# TODO:
#   - parse arguments and default "null" if not specified
#
# Arguments:
#   $1 - components - "component1,component2" or "null"
#   $2 - apps - "apps1,app2" or "null"
#   $3 - projects "project1, project2" or "null"
#
# NOTE:
#   - if one of the above is "null", it will build everything.
#   - it does not handle if "null,apis", avoid that.
#
main "$@"
