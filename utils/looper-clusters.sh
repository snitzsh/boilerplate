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
      local -a args_4=( \
        "${region_name}" \
        "${cluster_name}" \
      )

      case "${query_name}" in
        "create-cluster")
          clusterCreate "${args_4[@]}"
          ;;
        "delete-cluster")
          clusterDelete "${args_4[@]}"
          ;;
        "read-kubeconfig")
          clusterReadKubeconfig "${args_4[@]}"
          ;;
        *)
          ;;
      esac

      while IFS= read -r dependency_name; do
        if [ "${dependency_name}" == "argo" ]; then
          dependency_found="true"
          local -a args_5=( \
            "get-{region_name}-{cluster_name}-{dependencies_name}-charts-name" \
            "${region_name}" \
            "${cluster_name}" \
            "${dependency_name}" \
          )
          local chart_found="false"

          while IFS= read -r chart_name; do
            if [ "${chart_name}" == "argo-cd" ]; then
              chart_found="true"
              local -a args_6=( \
                "${region_name}" \
                "${cluster_name}" \
                "${dependency_name}" \
                "${chart_name}" \
              )
              (
                cd "${SNITZSH_PATH}/helm-charts/${dependency_name}/${chart_name}/${region_name}/${cluster_name}" &&
                case "${query_name}" in
                  "install-argo-cd")
                    clusterInstallArgoCD "${args_6[@]}"
                    ;;
                  *)
                    ;;
                esac
              )
            fi
          done < <(utilQueryClustersYaml "${args_5[@]}")
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
    done < <( \
      utilQueryClustersYaml "${args_2[@]}" \
    )
  done < <( \
    utilQueryClustersYaml "${args_1[@]}" \
  )
}
