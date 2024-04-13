#!/bin/bash

#
# TODO:
#   - return an (empty object or false) if a dependency cannot be found.
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Gets the specific dependency chart from ../hc-c-dependencies.yaml
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
function utilGetHelmChartDependency () {
  local -r helm_chart_dependencies_path="${PLATFORM_PATH}/boilerplate/hc-c-dependencies.yaml"
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
    ' "${helm_chart_dependencies_path}" \
  )
  echo "${dependency}"
}
