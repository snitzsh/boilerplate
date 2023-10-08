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
utilGetHelmChartDependecy () {
  local -r helm_charts_dependcies_path="${SNITZSH_PATH}/boilerplate/helm-chart-dependencies.yaml"
  local dependency_name="${1}"
  local chart_name="${2}"
  local dependency=""
  dependency=$( \
    # shellcheck disable=SC2016
    dependency_name="${dependency_name}" \
    chart_name="${chart_name}" \
    yq '
      env(dependency_name) as $dependency_name
      | env(chart_name) as $chart_name
      | .dependencies[]
      | select(.name == $dependency_name)
      | .repository as $repository
      | .charts[]
      | select(.name == $chart_name)
      | .dependency_name |= $dependency_name
      | .repository |= $repository
      | .
    ' "${helm_charts_dependcies_path}" \
  )
  echo "${dependency}"
}
