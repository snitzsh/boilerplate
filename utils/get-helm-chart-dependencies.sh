#!/bin/bash

# TODO:
# - Merge the function into one, just like in ./query-cluster-yaml.sh
# - name this functon and file to something like query-hc-c-dependencies.sh

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Get the all dependencies of the platform from ../hc-c-dependencies.yaml
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
function utilGetHelmChartDependecies () {
  local -a arr=()
  local -r helm_chart_dependencies_path="${PLATFORM_PATH}/boilerplate/hc-c-dependencies.yaml"
  while IFS='' read -r line; do arr+=("$line"); done < <(
    # yq doesn't have an easy way to return a bash array. So using jq is the
    # easiest way.
    yq -o=json '
      [
        .dependencies[]
        | {"dependency": .name, "chart": (.charts[].name)}
        | .dependency + "|" + .chart
      ]
    ' "${helm_chart_dependencies_path}" | jq -r '.[]'
  )
  echo "${arr[@]}"
}
