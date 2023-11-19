#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - it loops throught ../helm-chart-dependencies.yaml.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
utilLooperHelmChartDependecies () {
  local -r func_name="${FUNCNAME[0]}"
  local -r query_name="${1}"
  local dependencies=()

  while IFS='' read -r line; do dependencies+=("$line"); done < <(
    utilGetHelmChartDependecies | yq -r -o=json 'split(" ")' | jq -r '.[]'
  )

  local chart_name=""
  local dependency_name=""
  local file_dependency=""
  local -a args=()
  for dependency in "${dependencies[@]}"; do
    dependency_name=$(echo "${dependency}" | yq -r 'split("|") | .[0]')
    chart_name=$(echo "${dependency}" | yq -r 'split("|") | .[1]')

    file_dependency=$(utilGetHelmChartDependency "${dependency_name}" "${chart_name}")

    args=(
      "${dependency_name}"
      "${chart_name}"
      "${file_dependency}"
    )

    case "${query_name}" in
      "global-helm-install-repositories")
        funcGlobalHelmInstallRepositories "${args[@]}"
        ;;
      # TODO:
      #   - take this function out of this loop, make it on its
      #     own. This function executes only locally, without
      #     affecting the repo.
      "global-helm-update-repositories")
        funcGlobalHelmUpdateRepositories "${args[@]}"
        ;;
      "global-update-to-latest-version")
        funcGlobalHelmUpdateRepositories "${args[@]}"
        funcGlobalHelmChartDependenciesFileUpdateToLatestVersion "${args[@]}"
        ;;
      *)
        logger "ERROR" "'${query_name}' is not supported." "${func_name}"
        break
        ;;
    esac
  done
}
