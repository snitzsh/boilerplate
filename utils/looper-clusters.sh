#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - create a lint helm function to lint before committing.
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
utilLooperClusters () {
  local -r func_name="${FUNCNAME[0]}"
  local -r query_name="${1}"
  local -a regions_name_arr=()
  local -a args_1=( \
    "get-regions-name" \
  )

  # Get region names
  while IFS= read -r region_name; do
    local -a args_2=( \
      "get-{region_name}-clusters-name" \
      "${region_name}" \
    )

    # Get Clusters name
    while IFS= read -r cluster_name; do
      local dependency_found="false"
      # We only need argo-cd because it responsible to deploy the
      # services (including itself after installing manually for the first time)
      # and apps.
      local -a args_3=( \
        "get-{region_name}-{cluster_name}-dependencies-name" \
        "${region_name}" \
        "${cluster_name}" \
      )

      # HERE create cluster...
      # HERE delete cluster
      # HERE get .kubeconfig

      while IFS= read -r dependency_name; do
        if [ "${dependency_name}" == "argo" ]; then
          dependency_found="true"
          local -a args_4=( \
            "get-{region_name}-{cluster_name}-{dependencies_name}-charts-name" \
            "${region_name}" \
            "${cluster_name}" \
            "${dependency_name}" \
          )
          local chart_found="false"
          while IFS= read -r chart_name; do
            if [ "${chart_name}" == "argo-cd" ]; then
              chart_found="true"
            fi
          done < <(utilQueryClustersYaml "${args_4[@]}")

          # Logs
          if [ "${chart_found}" == "false" ]; then
            logger "ERROR" "Chart 'argo/argo-cd' not found." "$func_name"
          fi
        fi
      done < <(utilQueryClustersYaml "${args_3[@]}")

      # Logs
      if [ "${dependency_found}" == "false" ]; then
        logger "ERROR" "Dependency 'argo' not found." "$func_name"
      fi
    done < <(utilQueryClustersYaml "${args_2[@]}")
  done < <(utilQueryClustersYaml "${args_1[@]}")


  # (
  #   cd "$SNITZSH_PATH/helm-charts" &&
  #   for dependency_name in *; do
  #     echo "${dependency_name}"
  #     (
  #       cd "./${dependency_name}" &&
  #       for chart_name in *; do
  #         (
  #           cd "./${chart_name}" &&
  #           for region_name in "${regions_name_arr[@]}"; do
  #             echo "$region_name"
  #             # Get cluster names
  #             local -a clusters_name_arr=()
  #             local -a args_2=( \
  #               "get-{region_name}-clusters-name" \
  #               "${region_name}"
  #             )
  #             while IFS= read -r value; do
  #               clusters_name_arr+=("${value}")
  #             done < <(utilQueryClustersYaml "${args_2[@]}")

  #             for cluster_name in "${clusters_name_arr[@]}"; do
  #               # TODO:
  #               #   - should only run for north-america dev
  #               # NOTE:
  #               #   - Just runs if .helm_clusters is null.
  #               local -a args_3=( \
  #                 "post-{region_name}-{cluster-name}-helm-charts-dependencies" \
  #                 "${region_name}" \
  #                 "${cluster_name}" \
  #               )
  #               utilQueryClustersYaml "${args_3[@]}"
  #               sleep 1 # I/O Issues, needs timeout.
  #               # sub-shell
  #               (
  #                 cd "./${region_name}/${cluster_name}" &&
  #                 # TODO:
  #                 # - reorganize the arguments. dependency_name and chart_name should go first.
  #                 # - Update cluster file and before updating the chart.
  #                 # - Dev on each region by default should put the latest.
  #                 #   sit -> uat -> prod should get in steps. Ex. sit should get the dev dependencies by default (if doesn't exist)
  #                 local -a args_4=( \
  #                   "get-{region_name}-{cluster-name}-helm-charts-{dependency_name}-{chart_name}" \
  #                   "${region_name}" \
  #                   "${cluster_name}" \
  #                   "${dependency_name}" \
  #                   "${chart_name}" \
  #                 )
  #                 local -r file_dependency=$( \
  #                   utilQueryClustersYaml "${args_4[@]}" \
  #                 )
  #                 local -r file_dependency_chart_name=$(echo "${file_dependency}" | yq '.name')
  #                 local -r file_dependency_dependency_name=$(echo "${file_dependency}" | yq '.dependency_name')
  #                 local -r file_dependency_chart_lenguage=$(echo "${file_dependency}" | yq '.language')
  #                 local -a args=( \
  #                   "${dependency_name}" \
  #                   "${chart_name}" \
  #                   "${region_name}" \
  #                   "${cluster_name}" \
  #                   "${file_dependency}" \
  #                 )
  #                 if [[ "${dependency_name}" == "${file_dependency_dependency_name}" ]] \
  #                   && [[ "${chart_name}" == "${file_dependency_chart_name}" ]] \
  #                   && [[ "${file_dependency_chart_lenguage}" == "helm" ]]; then
  #                   # /snitzsh/helm-charts/<dependency-name>/<[chart-name]>/<[region-name]>/<[cluster-name]>/*
  #                   case "${query_name}" in
  #                     "create-cluster")
  #                       funcClusterCreateCluster "${args[@]}"
  #                       ;;
  #                     "delete-cluster")
  #                       funcClusterDeleteCluster "${args[@]}"
  #                       ;;
  #                     # /*
  #                     "install-argo-cd")
  #                       funcClusterInstallArgoCD "${args[@]}"
  #                       ;;
  #                     # ./Chart.yaml
  #                     "read-kubconfig")
  #                       funcClusterReadKubeconfig "${args[@]}"
  #                       ;;
  #                     *)
  #                       # echo "Function query does not exist."
  #                       ;;
  #                   esac
  #                 else
  #                   logger "ERROR" "Chart '${chart_name}' for dependency: '${dependency_name}' is not found in './helm-charts-dependencies.yaml'. Possible issues: 1) Make sure the repository name cloned follows the naming-convention. 2) Chart has been depricated from the helm-charts-dependencies.yaml and still have the repository cloned." "${func_name}"
  #                 fi
                # )
              # done
            # done
          # )
          # break
        # done
      # )
      # break
    # done
  # )
}
