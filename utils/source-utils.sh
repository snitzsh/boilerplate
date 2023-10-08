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
utilSourceUtils () {
  for util in "${SNITZSH_PATH}"/boilerplate/utils/*; do
    if [ "${util}" == "${SNITZSH_PATH}/boilerplate/utils/source-utils.sh" ]; then
      continue
    fi
    source "${util}"
  done
}

utilSourceUtils
