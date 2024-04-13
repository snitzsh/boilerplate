#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-r/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - Scan Dockerfile using hadolint and possibly creeate a report. Only for private repos
#   - user `clair` command to scan containers.
#   - maybe we much create a function to sync our helm-charts-configs/ and respositories in git.
#   - pull docker service generated in git@github.com:snitzsh/script-global-docker_compose-bash.git
#     and added dynamically added in each private repo to prevent maintaining multiple
#     docker-compose.yaml.
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
function main () {
  local -ar args=("$@")
  echo "${args[@]}"
  # utilLooperFoldersRepositories "${args[@]}"
}

main "$@"
