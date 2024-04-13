#!/bin/bash

#
# TODO:
#   - add desc, args, return
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
function utilQueryHelmChartConfigsDependenciesFile () {
  local -r helm_chart_dependencies_path="${PLATFORM_PATH}/boilerplate/hc-c-dependencies.yaml"
  local -r query_name="${1}"

  case "${query_name}" in
    "update-{dependency}-version")
      local -r dependency_name="${2}"
      local -r chart_name="${3}"
      local -r latest_version="${4}"
      # shellcheck disable=SC2016
      _dependency_name="${dependency_name}" \
      _chart_name="${chart_name}" \
      _latest_version="${latest_version}" \
      yq '
        env(_dependency_name) as $_dependency_name
        | env(_chart_name) as $_chart_name
        | env(_latest_version) as $_latest_version
        | (..)
      ' "${helm_chart_dependencies_path}"
      ;;
    *)
      echo ""
      ;;
  esac
}
