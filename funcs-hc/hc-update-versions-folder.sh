#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - null
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
funcHelmChartUpdateVersionsFolder () {
  local -r func_name="${FUNCNAME[0]}"
  local -r args=("$@")
  local -r dependency_name="${args[0]}"
  local -r chart_name="${args[1]}"
  local -r region_name="${args[2]}"
  local -r cluster_name="${args[3]}"
  local -r file_dependency="${args[4]}"

  if [ -f "./Chart.yaml" ]; then
    echo "${file_dependency}"
  fi
}