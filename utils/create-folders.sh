#!/bin/bash

#
# TODO:
#   - integrate plural REPOSITORY_NAME_IDS
#   - I don't think this is necessary since we are using mkdri -p ...
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Creates folders recursebly to ensure it always exit without creating them
#     manually
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function utilCreateFolders () {
  local -r arr=(
  )
  for folder in "${arr[@]}"; do
    mkdir -p "${PLATFORM_PATH}/$folder"
  done
}
