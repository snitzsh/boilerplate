#!/bin/bash

#
# TODO:
#   - create a lint helm function to lint before committing.
#
# NOTE:
#   - it loops throught the repositories cloned. ../helm-charts-configs/ directory.
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
function utilLooperHelmChartConfigsRepositories () {
  local -r func_name="${FUNCNAME[0]}"
  local -r query_name="${1}"
  local -a args=( \
    "get-regions-name" \
  )

  (
    cd "${PLATFORM_PATH}/helm-charts-configs" &&
    for dependency_name in *; do
      local initial_chart_name=""
      # if-statement for testing purposes
      # if [ "${dependency_name}" != "snitzsh" ]; then
      #   continue
      # fi
      (
        cd "./${dependency_name}" &&
        for chart_name in *; do
          initial_chart_name="${chart_name}"
          (
            cd "./${chart_name}" &&

            # loops region names
            while IFS= read -r region_name; do
              # Get cluster names
              local -a args_3=( \
                "get-{region_name}-clusters-name" \
                "${region_name}"
              )
              # lopps cluster names
              while IFS= read -r cluster_name; do
                # TODO:
                #   - should only run for north-america dev
                #     when we are ready to update the qa, we do clone and
                #     update each values.yaml for a higher environment.
                #     make sure the funcionality includes update per chart.
                #
                # NOTE:
                #   - Just runs if .helm_clusters is null.
                local -a args_4=( \
                  "post-{region_name}-{cluster-name}-helm-charts-dependencies" \
                  "${region_name}" \
                  "${cluster_name}" \
                )
                echo "Region name: ${region_name}"
                echo "Cluster name : ${cluster_name}"
                utilQueryClustersYaml "${args_4[@]}"
                sleep 1 # I/O Issues, needs timeout.
                # sub-shell
                mkdir -p ./"${region_name}/${cluster_name}"
                (
                  cd "./${region_name}/${cluster_name}" &&
                  # TODO:
                  # - reorganize the arguments. dependency_name and chart_name should go first.
                  # - Update cluster file and before updating the chart.
                  # - Dev on each region by default should put the latest.
                  #   sit -> uat -> prod should get in steps. Ex. sit should get the dev dependencies by default (if doesn't exist)
                  local -a args_5=("${dependency_name}" "${chart_name}" "${initial_chart_name}")
                  chart_name=$(utilProprietaryChartNameChanger "${args_5[@]}")

                  local -a args_6=( \
                      "read-{region_name}-{cluster_name}-helm-charts-{dependency_name}-{chart_name}" \
                      "${region_name}" \
                      "${cluster_name}" \
                      "${dependency_name}" \
                      "${chart_name}" \
                  )

                  local -r file_dependency=$( \
                    utilQueryClustersYaml "${args_6[@]}" \
                  )
                  local -r file_dependency_chart_name=$(echo "${file_dependency}" | yq '.name')
                  local -r file_dependency_dependency_name=$(echo "${file_dependency}" | yq '.dependency_name')
                  local -r file_dependency_chart_lenguage=$(echo "${file_dependency}" | yq '.language')

                  # exit 1
                  if [[ "${dependency_name}" == "${file_dependency_dependency_name}" ]] \
                    && [[ "${chart_name}" == "${file_dependency_chart_name}" ]] \
                    && [[ "${file_dependency_chart_lenguage}" == "helm" ]]; then
                    chart_name="${initial_chart_name}"
                    local -a args_7=( \
                      "${dependency_name}" \
                      "${chart_name}" \
                      "${region_name}" \
                      "${cluster_name}" \
                      "${file_dependency}" \
                      "${initial_chart_name}" \
                    )
                    # /$PLATFORM/helm-charts-configs/<dependency-name>/<[chart-name]>/<[region-name]>/<[cluster-name]>/*
                    case "${query_name}" in
                      # Done migrating
                      "hc-c-create-helm-chart")
                        funcHelmChartConfigsCreateChart "${args_7[@]}"
                        funcHelmChartConfigsUpdateChartYamlFile "${args_7[@]}"
                        funcHelmChartConfigsUpdateValuesAddDependencyNameAsProperty "${args_7[@]}"
                        ;;
                      "hc-c-create-_helpers-file")
                        funcHelmChartConfigs_HelpersFile "${args_7[@]}"
                        ;;
                      # TODO:
                      #   - currently function does nothing.
                      # ./values.yaml
                      # Done migrating
                      "hc-c-get-values")
                        funcHelmChartConfigsGetValues "${args_7[@]}"
                        ;;
                      "hc-c-update-versions-folder")
                        # TODO:
                        # - make sure the `bash main.sh g-clusters-file-put-to-latest-version`
                        #   is always executed first.`
                        funcHelmChartConfigsUpdateVersionsFolder "${args_7[@]}"
                        ;;
                      "hc-c-update-chart-yaml-file")
                        funcHelmChartConfigsUpdateChartYamlFile "${args_7[@]}"
                        funcHelmChartConfigsUpdateValuesAddDependencyNameAsProperty "${args_7[@]}"
                        ;;
                      "hc-c-update-values-file-add-dependency-name-as-property")
                        funcHelmChartConfigsUpdateValuesAddDependencyNameAsProperty "${args_7[@]}"
                        ;;
                      "hc-c-update-ignore-file-helmignore")
                        local -a args_8=(".helmignore" "${args_7[@]}")
                        utilHelmChartConfigsUpdateIgnoreFiles "${args_8[@]}"
                        ;;
                      # ./
                      "hc-c-update-version")
                        # TODO:
                        #   - This should never be allow beyond dev clusters.
                        #   - make sure when update hc-c-...-configs to newer version the argo-cd.main.dependecies
                        #     are also updated.
                        funcHelmChartConfigsUpdateVersion "${args_7[@]}"
                        ;;
                      "hc-c-linter")
                        echo ""
                        ;;
                      *)
                        # echo "Function query does not exist."
                        ;;
                    esac
                  else
                    logger "ERROR" "Chart '${chart_name}' for dependency: '${dependency_name}' is not found in './helm-charts-dependencies.yaml'. Possible issues: 1) Make sure the repository name cloned follows the naming-convention. 2) Chart has been depricated from the helm-charts-dependencies.yaml and still have the repository cloned." "${func_name}"
                  fi
                )
              done < <(utilQueryClustersYaml "${args_3[@]}")
            done < <(utilQueryClustersYaml "${args[@]}")
          )
          # break
        done
      )
      # break
    done
  )
}
