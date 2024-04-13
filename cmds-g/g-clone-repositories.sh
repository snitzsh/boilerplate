#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - Create flags/options to pass in when executing this script through cli.
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

source "${PLATFORM_PATH}/boilerplate/funcs-g/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

function main () {
  utilCreateFolders
  utilGetRepositories
  funcCloneRepositories
}

main
