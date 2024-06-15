#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - it loops throught ../hc-c-dependencies.yaml.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function utilLooperHelmChartConfigsDependecies () {
  local -r func_name="${FUNCNAME[0]}"
  local -a args=("$@")
  local -r query_name=$(utilReadArgValue "${func_name}" "null" "query-name" "${args[0]}")
  local dependencies=()

  while IFS='' read -r line; do dependencies+=("$line"); done < <(
    utilGetHelmChartDependecies | yq -r -o=json 'split(" ")' | jq -r '.[]'
  )

  local chart_name=""
  local dependency_name=""
  local file_dependency=""
  local -a args_1=()
  for dependency in "${dependencies[@]}"; do
    dependency_name=$(echo "${dependency}" | yq -r 'split("|") | .[0]')
    chart_name=$(echo "${dependency}" | yq -r 'split("|") | .[1]')

    file_dependency=$(utilGetHelmChartDependency "${dependency_name}" "${chart_name}")

    args_1=(
      "${dependency_name}"
      "${chart_name}"
      "${file_dependency}"
    )

    case "${query_name}" in
      "g-helm-install-repositories")
        funcGlobalHelmInstallRepositories "${args_1[@]}"
        ;;
      # TODO:
      #   - take this function out of this loop, make it on its
      #     own. This function executes only locally, without
      #     affecting the repo.
      "g-helm-update-repositories")
        funcGlobalHelmUpdateRepositories "${args_1[@]}"
        ;;
      "g-helm-chart-dependencies-file-update-to-latest-version")
        funcGlobalHelmUpdateRepositories "${args_1[@]}"
        funcGlobalHelmChartDependenciesFileUpdateToLatestVersion "${args_1[@]}"
        ;;
      *)
        logger "ERROR" "'${query_name}' is not supported." "${func_name}"
        break
        ;;
    esac
  done
}
