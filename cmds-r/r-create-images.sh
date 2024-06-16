#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-r/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - null
#
# NOTE:
#   - read flags.yanl file
#
# DESCRIPTION:
#   - read flags.yanl file
#
# ARGS:
#   - read flags.yanl file
#
# RETURN:
#   - null
#
function main () {
  local -ar args=("$@")
  utilLooperRRepositories "${args[@]}"
}

main "$@"