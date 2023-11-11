#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Does add, commit push.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
utilGitter () {
  local -r args=("$@")
  local -r func_name="${args[0]}"
  local -r log_msg="${args[1]}"
  git add .
  # this ensures only commit and push if there are changes.
  git diff --staged --quiet || (
    git commit --quiet -m "${log_msg}" > /dev/null &&
    git push --quiet
    logger "INFO" "${log_msg}" "${func_name}"
    sleep 5
  )
}
