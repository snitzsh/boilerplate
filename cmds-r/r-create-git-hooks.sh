#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-r/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - maybe we much create a function to sync our helm-charts-configs/ and respositories in git.
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Exectues the function(s)
#
# ARGS:
#   - $1 : query_name       : r-create-git-hooks                : query name to be executed.
#   - $2 : folder_name      : <[folder_name]>                   : which forder to target
#   - $4 : dependency_name  : <[dependency_name | app_name]>    : depenency to update
#   - $4 : chart_name       : <[chart_name]>                    : chart to update
#
# RETURN:
#   - null
#
main () {
  local -ar args=("$@")
  utilLooperFoldersRepositories "${args[@]}"
}

main "$@"
