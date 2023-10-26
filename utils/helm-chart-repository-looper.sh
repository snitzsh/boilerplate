#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - null
#
# NOTE:
#   - it loops throught the repositories cloned. ../helm-charts/ directory.
#
# DESCRIPTION:
#   - Creates values files
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
utilHelmChartRepositoryLooper () {
  local -r func_name="${FUNCNAME[0]}"
  local -a regions_name_arr=()
  local -a query_name="${1}"
  # Get region names
  while IFS= read -r value; do
    regions_name_arr+=("${value}")
  done < <(utilQueryClustersYaml "get-regions-name")

  (
    cd "$SNITZSH_PATH/helm-charts" &&
    for dependency_name in *; do
      local chart_name=""
      for chart in  "${dependency_name}/"*; do
        chart_name=$(echo "${chart}" | yq -r 'split("/") | .[1]')
        for region_name in "${regions_name_arr[@]}"; do
          # Get cluster names
          local -a clusters_name_arr=()
          while IFS= read -r value; do
            clusters_name_arr+=("${value}")
          done < <(utilQueryClustersYaml "get-{region_name}-clusters-name" "${region_name}")

          for cluster_name in "${clusters_name_arr[@]}"; do
            (
              cd "./${dependency_name}/${chart_name}" &&
              mkdir -p ./"${region_name}/${cluster_name}"
              (
                cd "./${region_name}/${cluster_name}" &&
                # ../helm-charts-dependencies.yaml dependency
                local -r file_dependency=$(utilGetHelmChartDependency "${dependency_name}" "${chart_name}")
                local -r file_dependency_chart_name=$(echo "${file_dependency}" | yq '.name')
                local -r file_dependency_dependency_name=$(echo "${file_dependency}" | yq '.dependency_name')
                local -r file_dependency_chart_lenguage=$(echo "${file_dependency}" | yq '.language')
                local -a args=( \
                  "${region_name}" \
                  "${cluster_name}" \
                  "${dependency_name}" \
                  "${chart_name}" \
                  "${file_dependency}" \
                )
                if [[ "${dependency_name}" == "${file_dependency_dependency_name}" ]] \
                  && [[ "${chart_name}" == "${file_dependency_chart_name}" ]] \
                  && [[ "${file_dependency_chart_lenguage}" == "helm" ]]; then
                  case "${query_name}" in
                    "create-chart")
                      utilHelmChartCreateChart "${args[@]}"
                      ;;
                    # repo/Chart.yaml
                    "patch-chart-yaml-file")
                      utilHelmChartPatchChartYamlFile "${args[@]}"
                      ;;
                    "helm-update-repositories")
                      utilHelmUpdateRepositories "${args[@]}"
                      ;;
                    "get-values")
                      utilHelmChartGetValues "${args[@]}"
                      ;;
                    "sync-versions")
                      utilSyncHelmChartVersions "${args[@]}"
                      ;;
                    *)
                      echo ""
                      ;;
                  esac
                else
                  logger "ERROR" "Chart '${chart_name}' for dependency: '${dependency_name}' is not found in './helm-charts-dependencies.yaml'. Possible issues: 1) Make sure the repository name cloned follows the naming-convention. 2) Chart has been depricated from the helm-charts-dependencies.yaml and still have the repository cloned." "${func_name}"
                fi
              )
            )
          done
        done
      done
    done
  )
}
