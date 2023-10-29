#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - Only allow it for north-america dev
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - it loops throught ../clusters.yaml.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
utilLooperClustersHelmCharts () {
  local -r func_name="${FUNCNAME[0]}"
  local -r query_name="${1}"
  local -a regions_name_arr=()
  local -a args_1=( \
    "get-regions-name" \
  )

  # Get region names
  while IFS= read -r value; do
    regions_name_arr+=("${value}")
  done < <(utilQueryClustersYaml "${args_1[@]}")

  for region_name in "${regions_name_arr[@]}"; do

    local -a clusters_name_arr=()
    local -a args_2=( \
      "get-{region_name}-clusters-name" \
      "${region_name}"
    )
    while IFS= read -r value; do
      clusters_name_arr+=("${value}")
    done < <(utilQueryClustersYaml "${args_2[@]}")
    for cluster_name in "${clusters_name_arr[@]}"; do
      local -a dependencies_name_arr=()
      local -a args_3=( \
        "get-{region_name}-{cluster_name}-dependencies-name" \
        "${region_name}" \
        "${cluster_name}" \
      )
      while IFS= read -r value; do
        dependencies_name_arr+=("${value}")
      done < <(utilQueryClustersYaml "${args_3[@]}")
      for dependency_name in "${dependencies_name_arr[@]}"; do
        local -a charts_name_arr=()
        local -a args_4=( \
          "get-{region_name}-{cluster_name}-{dependencies_name}-charts-name" \
          "${region_name}" \
          "${cluster_name}" \
          "${dependency_name}" \
        )
        while IFS= read -r value; do
          charts_name_arr+=("${value}")
        done < <(utilQueryClustersYaml "${args_4[@]}")
        local file_dependency=""
        local file_dependency_chart_name=""
        local file_dependency_dependency_name=""
        local file_dependency_chart_lenguage=""
        local args_5=()
        for chart_name in "${charts_name_arr[@]}"; do
          local -a args_4=( \
            "get-{region_name}-{cluster-name}-helm-charts-{dependency_name}-{chart_name}" \
            "${region_name}" \
            "${cluster_name}" \
            "${dependency_name}" \
            "${chart_name}" \
          )
          file_dependency=$( \
            utilQueryClustersYaml "${args_4[@]}" \
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
            local -a args_6=( \
              "${dependency_name}" \
              "${chart_name}" \
              "${file_dependency}" \
            )
            case "${query_name}" in
              "g-clusters-put-{dependency_name}-{chart_name}-to-latest-version")
                funcGlobalHelmUpdateRepositories "${args_6[@]}"
                funcClustersYamlPutDependencyChartToLatestVersion "${args_5[@]}"
                ;;
              *)
                logger "ERROR" "'${query_name}' is not supported." "${func_name}"
                break
                ;;
            esac
          fi
        done
      done
    done
  done
}
