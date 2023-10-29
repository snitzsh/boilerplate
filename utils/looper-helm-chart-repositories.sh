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
utilLooperHelmChartRepositories () {
  local -r func_name="${FUNCNAME[0]}"
  local -a regions_name_arr=()
  local -r query_name="${1}"
  local -a args_1=( \
    "get-regions-name" \
  )
  # Get region names
  while IFS= read -r value; do
    regions_name_arr+=("${value}")
  done < <(utilQueryClustersYaml "${args_1[@]}")

  (
    cd "$SNITZSH_PATH/helm-charts" &&
    for dependency_name in *; do
      local chart_name=""
      for chart in  "${dependency_name}/"*; do
        chart_name=$(echo "${chart}" | yq -r 'split("/") | .[1]')
        for region_name in "${regions_name_arr[@]}"; do
          # Get cluster names
          local -a clusters_name_arr=()
          local -a args_2=( \
            "get-{region_name}-clusters-name" \
            "${region_name}"
          )
          while IFS= read -r value; do
            clusters_name_arr+=("${value}")
          done < <(utilQueryClustersYaml "${args_2[@]}")

          for cluster_name in "${clusters_name_arr[@]}"; do
            local -a args_3=( \
              "post-{region_name}-{cluster-name}-helm-charts-dependencies" \
              "${region_name}" \
              "${cluster_name}" \
            )
            utilQueryClustersYaml "${args_3[@]}"
            exit 1
            # sub-shell
            (
              cd "./${dependency_name}/${chart_name}" &&
              mkdir -p ./"${region_name}/${cluster_name}"
              (
                cd "./${region_name}/${cluster_name}" &&
                # ../helm-charts-dependencies.yaml dependency
                # TODO:
                # - Onces the global-helm-update-repositories is on its own
                #   this should query the dependecies cluster dependencies, instead of the global dependecies.
                #   global dependeices will always have the latest, and cluster dependencies will have what's currently running.
                #   crete a new function targetitng the global dependecies.
                # - Update cluster file and before updating the chart.
                # - make sure other cmds calls the cluster.yaml instead of the helm-chart-dependencies-file
                # - Dev on each region by default should put the latest.
                #   sit -> uat -> prod should get in steps. Ex. sit should get the dev dependencies by default (if doesn't exist)
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
                    # <[repo]>/*
                    "create-helm-chart")
                      utilHelmChartCreateChart "${args[@]}"
                      ;;
                    # repo/Chart.yaml
                    "patch-chart-yaml-file")
                      utilHelmChartPatchChartYamlFile "${args[@]}"
                      ;;
                    # <[repo]>/*
                    "get-values")
                      utilHelmChartGetValues "${args[@]}"
                      ;;
                    # <[repo]>/*
                    "update-versions")
                      # TODO: This should never be allow beyond dev clusters.
                      funcHelmChartUpdateVersions "${args[@]}"
                      ;;
                    *)
                      echo "Function query does not exist."
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
