#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-r/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - maybe we much create a function to sync our helm-charts/ and respositories in git.
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
  utilLooperFoldersRepositories "${args[@]}"
}

main "$@"
