#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-r/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - null
#
# NOTE:
#   - Excution ex:
#     ```bash
#     bash main.sh r-create-images \
#       --components="apis,uis" \
#       --apps="snitzsh" \
#       --projects="main-rust,main-vue"
#     ```
#
# DESCRIPTION:
#   - null
#
# ARGS:
#   - --components="component_1,component_2"
#   - --apps="app_1,app_2"
#   - --projects="project_1,project_2"
#
# RETURN:
#   - null
#
function main () {
  local -ar args=("$@")
  utilLooperRRepositories "${args[@]}"
}

main "$@"
