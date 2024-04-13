#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - for proprietary chart it may poiint to different chart, so it doesn't
#     follow the same rules are 3rd party charts.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function utilProprietaryChartNameChanger () {
  local -r func_name="${FUNCNAME[0]}"
  local -r args=("$@")
  local -r dependency_name="${args[0]}"
  local chart_name="${args[1]}"
  local -r initial_chart_name="${args[2]}"

  if [ "${dependency_name}" == "snitzsh" ]; then
    if [ "${chart_name}" == "api-main" ]; then
      chart_name="apis"
    fi
    if [ "${chart_name}" == "ui-main" ]; then
      chart_name="uis"
    fi
  fi
  echo "${chart_name}"
}
