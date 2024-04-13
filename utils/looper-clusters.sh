#!/bin/bash

#
# TODO:
#   - create a lint helm function to lint before committing.
#   - probably it needs to select the specific cluster depeneding on the args
#     using yq, that way no loop will be need it.
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
function utilLooperClusters () {
  local -r func_name="${FUNCNAME[0]}"
  local -a args=("$@")
  local -r query_name="${args[0]}"
  local -r cluster_type="${args[1]}"
  local -r region_name_to_build="${args[2]}"
  local -r cluster_name_to_build="${args[3]}"
  local -a args_1=( \
    "get-regions-name" \
  )
  local case_executed="false"

  # Get region names
  while IFS= read -r region_name; do
    if [ "${region_name}" == "${region_name_to_build}" ]; then
      local -a args_2=( \
        "get-{region_name}-clusters-name" \
        "${region_name}" \
      )
      # Get Clusters name
      while IFS= read -r cluster_name; do
        if [ "${cluster_name}" == "${cluster_name_to_build}" ]; then
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
            "${cluster_type}" \
            "${region_name}" \
            "${cluster_name}" \
          )

          case "${query_name}" in
            "c-create-cluster")
              clusterCreate "${args_4[@]}"
              case_executed="true"
              ;;
            "c-delete-cluster")
              clusterDelete "${args_4[@]}"
              case_executed="true"
              ;;
            "c-read-kubeconfig")
              clusterReadKubeconfig "${args_4[@]}"
              case_executed="true"
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
                    "${cluster_type}" \
                    "${region_name}" \
                    "${cluster_name}" \
                    "${dependency_name}" \
                    "${chart_name}" \
                  )
                  (
                    cd "${PLATFORM_PATH}/helm-charts-configs/${dependency_name}/${chart_name}/${region_name}/${cluster_name}" &&
                    case "${query_name}" in
                      "c-install-argo-cd")
                        clusterInstallArgoCD "${args_6[@]}"
                        ;;
                      *)
                        if [ "${case_executed}" == "false" ]; then
                          logger "ERROR" "Query name '${query_name}' does not exist." "${func_name}"
                        fi
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
        fi
      done < <( \
        utilQueryClustersYaml "${args_2[@]}" \
      )
    fi
  done < <( \
    utilQueryClustersYaml "${args_1[@]}" \
  )
}
