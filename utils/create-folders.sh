#!/bin/bash

#
# TODO:
#   - null
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
utilCreateFolders () {
  local -r arr=(
    "apps"
    "helm-charts"
  )
  for folder in "${arr[@]}"; do
    mkdir -p "${SNITZSH_PATH}/$folder"
  done
}
