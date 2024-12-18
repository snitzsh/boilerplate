#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - source file to access function in other script files.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function utilSourceUtils () {
  for util in "${PLATFORM_PATH}"/boilerplate/utils/*; do
    if [ "${util}" == "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh" ]; then
      continue
    fi
    source "${util}"
  done
}

utilSourceUtils
