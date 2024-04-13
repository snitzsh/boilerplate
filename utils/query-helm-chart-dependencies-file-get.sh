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
function utilQueryHelmChartDependenciesFileGET () {
  local -r helm_chart_dependencies_path="${PLATFORM_PATH}/boilerplate/hc-c-dependencies.yaml"
  local -ar args=("$@")
  local -r query_name="${args[0]}"
  case "${query_name}" in
    "get-{dependency}-{chart}-prop")
      local -r dependency_name="${args[1]}"
      local -r chart_name="${args[2]}"
      local -r prop="${args[3]}"
        _dependency_name="${dependency_name}" \
        _chart_name="${chart_name}" \
        _prop="${prop}" \
        yq \
          -r \
          '
            .dependencies[]
            | select(.name == env(_dependency_name))
            | .charts[]
            | select(.name == env(_chart_name))
            | .[env(_prop)]
          ' "${helm_chart_dependencies_path}" \
      ;;
    *)
      echo ""
      ;;
  esac
}

