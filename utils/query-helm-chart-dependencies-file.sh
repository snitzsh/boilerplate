#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Get the all dependencies of the platform from ../helm-chart-dependencies.yaml
#
# ARGS:
#   - null
#
# RETURN:
#   - Array  : dependencies
#     * example >
#     *   (argo.argo-cd argo.argo-workflows)
#
#
utilGetHelmChartDependecies () {
  local -a arr=()
  local -r helm_charts_dependcies_path="${SNITZSH_PATH}/boilerplate/helm-chart-dependencies.yaml"
  while IFS='' read -r line; do arr+=("$line"); done < <(
    # yq doesn't have an easy way to return a bash array. So using jq is the
    # easiest way.
    yq -o=json '
      [
        .dependencies[]
        | {"dependency": .name, "chart": (.charts[].name)}
        | .dependency + "|" + .chart
      ]
    ' "${helm_charts_dependcies_path}" | jq -r '.[]'
  )
  echo "${arr[@]}"
}

#
# TODO:
#   - return an (empty object or false) if a dependency cannot be found.
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Gets the specific dependency chart from ../helm-chart-dependencies.yaml
#
# ARGS:
#   - dependency_name
#   - chart_name
#
# RETURN:
#   - String  : `dependency chart object` OR `false`
#     * example >
#     *   '{...}'
#
#
utilGetHelmChartDependency () {
  local -r helm_charts_dependcies_path="${SNITZSH_PATH}/boilerplate/helm-chart-dependencies.yaml"
  local -r dependency_name="${1}"
  local -r chart_name="${2}"
  local dependency=""
  dependency=$( \
    # shellcheck disable=SC2016
    _dependency_name="${dependency_name}" \
    _chart_name="${chart_name}" \
    yq '
      env(_dependency_name) as $_dependency_name
      | env(_chart_name) as $_chart_name
      | .dependencies[]
      | select(.name == $_dependency_name)
      | .repository as $repository
      | .charts[]
      | select(.name == $_chart_name)
      | .dependency_name |= $_dependency_name
      | .repository |= $repository
      | .
    ' "${helm_charts_dependcies_path}" \
  )
  echo "${dependency}"
}

utilQueryHelmChartDependenciesFile () {
  local -r helm_charts_dependcies_path="${SNITZSH_PATH}/boilerplate/helm-chart-dependencies.yaml"
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
      ' "${helm_charts_dependcies_path}"
      ;;
    *)
      echo ""
      ;;
  esac
}
