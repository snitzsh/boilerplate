#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Update the helm-chart version if it meets the necessary criteria.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
funcHelmChartUpdateVersion () {
  local -r func_name="${FUNCNAME[0]}"
  local -r args=("$@")
  local -r region_name="${args[0]}"
  local -r cluster_name="${args[1]}"
  local -r dependency_name="${args[2]}"
  local -r chart_name="${args[3]}"
  local -r file_dependency="${args[4]}"

  if [ -f "./Chart.yaml" ]; then
    echo "${region_name}"
  fi
}
