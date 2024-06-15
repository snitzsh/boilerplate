#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-r/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - finish functionality
#   - Scan Dockerfile using hadolint and possibly creeate a report. Only for private repos
#   - user `clair` command to scan containers.
#   - maybe we much create a function to sync our helm-charts-configs/ and respositories in git.
#   - pull docker service generated in git@github.com:snitzsh/script-global-docker_compose-bash.git
#     and added dynamically added in each private repo to prevent maintaining multiple
#     docker-compose.yaml.
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
