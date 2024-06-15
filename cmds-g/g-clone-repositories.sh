#!/bin/bash
# shellcheck source=/dev/null


source "${PLATFORM_PATH}/boilerplate/funcs-g/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - do this code belongs on `cmds-g` or `cmds-r` folder? for consistency
#     this belongs in repositories.
#
# NOTE
#   - only the boilerplate repository MUST BE cloned manually!!!!
#
#
# DESCRIPTION:
# - This script will only clone what exits. It will not create a repo
#
#
function main () {
  utilCreateFolders
  utilGetRepositories
  funcCloneRepositories
}

main "$@"
