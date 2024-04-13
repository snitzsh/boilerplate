#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - it loops throught `../hc-dependencies.yaml`
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#

function utilLooperHelmChartDependeciesFile () {
  local -r func_name="${FUNCNAME[0]}"
  local -r query_name="${1}"
  local -a args_1=( \
    "read-hc-as-paths" \
  )
  while IFS= read -r hc_path; do
    ( cd "${PLATFORM_PATH}/helm-charts/${hc_path}" &&
      local dependency_name
      dependency_name=$( \
        # shellcheck disable=SC2016
        _hc_path="${hc_path}" \
        yq \
          -nr \
          '
            env(_hc_path) as $_hc_path
            | $_hc_path
            | . | split("/")
            | .[0]
          ' \
      )
      local chart_name
      chart_name=$( \
        # shellcheck disable=SC2016
        _hc_path="${hc_path}" \
        yq \
          -nr \
          '
            env(_hc_path) as $_hc_path
            | $_hc_path
            | . | split("/")
            | .[1]
          ' \
      )
      local -a args_2=( \
        "${dependency_name}" \
        "${chart_name}" \
      )
      case "${query_name}" in
        "hc-create-helm-chart")
            funcHelmChartCreateChart "${args_2[@]}"
          ;;
        "hc-create-_helpers-file")
          funcHelmChart_HelpersFile "${args_2[@]}"
          ;;
        "hc-update-helmignore-file")
            local -a args_3=(".helmignore" "${args_2[@]}")
            utilHelmChartConfigsUpdateIgnoreFiles "${args_3[@]}"
          ;;
        *)
          logger "ERROR" "Unknown query name '${query_name}'." "${func_name}"
          ;;
      esac
    )
  done  < <(utilQueryHelmChartDependenciesFile "${args_1[@]}")
}
