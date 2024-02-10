#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - make sure Only allow it for north-america dev or minikube/kind
#   - maybe move this loop to looper-cluster.sh
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - it loops throught ../clusters.yaml.
#
# ARGS:
#   - $1  : STRING  :  <[query_name]>  :  query name to be executed.
#
# RETURN:
#   - null
#
utilLooperClustersHelmCharts () {
  local -r func_name="${FUNCNAME[0]}"
  local -r query_name="${1}"
  local -a args_1=( \
    "get-regions-name" \
  )

  # Get region names
  while IFS= read -r region_name; do
    local -a args_2=( \
      "get-{region_name}-clusters-name" \
      "${region_name}" \
    )

    while IFS= read -r cluster_name; do
      local -a args_3=( \
        "get-{region_name}-{cluster_name}-dependencies-name" \
        "${region_name}" \
        "${cluster_name}" \
      )
      while IFS= read -r dependency_name; do
        local -a args_4=( \
          "get-{region_name}-{cluster_name}-{dependencies_name}-charts-name" \
          "${region_name}" \
          "${cluster_name}" \
          "${dependency_name}" \
        )
        local file_dependency=""
        local file_dependency_chart_name=""
        local file_dependency_dependency_name=""
        # local file_dependency_chart_lenguage=""
        local args_5=()

        while IFS= read -r chart_name; do
          local -a args_6=( \
            "read-{region_name}-{cluster_name}-helm-charts-{dependency_name}-{chart_name}" \
            "${region_name}" \
            "${cluster_name}" \
            "${dependency_name}" \
            "${chart_name}" \
          )
          file_dependency=$( \
            utilQueryClustersYaml "${args_6[@]}" \
          )
          file_dependency_chart_name=$(echo "${file_dependency}" | yq '.name')
          file_dependency_dependency_name=$(echo "${file_dependency}" | yq '.dependency_name')
          args_5=(
            "${region_name}"
            "${cluster_name}"
            "${dependency_name}"
            "${chart_name}"
            "${file_dependency}"
          )
          if [[ "${dependency_name}" == "${file_dependency_dependency_name}" ]] \
            && [[ "${chart_name}" == "${file_dependency_chart_name}" ]]; then
            local -a args_7=( \
              "${dependency_name}" \
              "${chart_name}" \
              "${file_dependency}" \
            )
            case "${query_name}" in
              "g-clusters-file-update-to-latest-version")
                funcGlobalHelmUpdateRepositories "${args_7[@]}"
                funcClustersFileUpdateToLatestVersion "${args_5[@]}"
                ;;
              *)
                logger "ERROR" "'${query_name}' is not supported." "${func_name}"
                break
                ;;
            esac
          fi
        done < <(utilQueryClustersYaml "${args_4[@]}")
      done < <(utilQueryClustersYaml "${args_3[@]}")
    done < <(utilQueryClustersYaml "${args_2[@]}")
  done < <(utilQueryClustersYaml "${args_1[@]}")
}
