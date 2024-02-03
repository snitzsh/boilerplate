#!/bin/bash
# shellcheck source=/dev/null

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
utilLooperHelmChartConfigsRepositories () {
  local -r func_name="${FUNCNAME[0]}"
  local -r query_name="${1}"
  local -a args_1=( \
    "get-regions-name" \
  )

  (
    cd "${PLATFORM_PATH}/helm-charts-configs" &&
    for dependency_name in *; do
      local initial_chart_name=""
      # if-statement for testing purposes
      if [ "${dependency_name}" != "snitzsh" ]; then
        continue
      fi
      (
        cd "./${dependency_name}" &&
        for chart_name in *; do
          initial_chart_name="${chart_name}"
          (
            cd "./${chart_name}" &&
            case "${query_name}" in
              # TODO: move this to another looper.
              "r-update-ignore-file-gitignore")
                local -a args_6=( \
                  '.gitignore' \
                  "${dependency_name}" \
                  "${chart_name}" \
                )
                utilHelmChartConfigsUpdateIgnoreFiles "${args_6[@]}"
                ;;
              "r-create-git-hooks")
                # TODO:
                # - make sure you run `bash main.sh hc-update-helmignore-file`
                #   after it executes this function.
                funcRepositoryCreateGitHooks "${args_6[@]}"
                ;;
              *)
                ;;
            esac
            # loops region names
            while IFS= read -r region_name; do
              # Get cluster names
              local -a args_2=( \
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
                local -a args_3=( \
                  "post-{region_name}-{cluster-name}-helm-charts-dependencies" \
                  "${region_name}" \
                  "${cluster_name}" \
                )
                echo "Region name: ${region_name}"
                echo "Cluster name : ${cluster_name}"
                utilQueryClustersYaml "${args_3[@]}"
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
                  local -a args_7=("${dependency_name}" "${chart_name}" "${initial_chart_name}")
                  chart_name=$(utilProprietaryChartNameChanger "${args_7[@]}")

                  local -a args_4=( \
                      "read-{region_name}-{cluster_name}-helm-charts-{dependency_name}-{chart_name}" \
                      "${region_name}" \
                      "${cluster_name}" \
                      "${dependency_name}" \
                      "${chart_name}" \
                  )

                  local -r file_dependency=$( \
                    utilQueryClustersYaml "${args_4[@]}" \
                  )
                  local -r file_dependency_chart_name=$(echo "${file_dependency}" | yq '.name')
                  local -r file_dependency_dependency_name=$(echo "${file_dependency}" | yq '.dependency_name')
                  local -r file_dependency_chart_lenguage=$(echo "${file_dependency}" | yq '.language')

                  # exit 1
                  if [[ "${dependency_name}" == "${file_dependency_dependency_name}" ]] \
                    && [[ "${chart_name}" == "${file_dependency_chart_name}" ]] \
                    && [[ "${file_dependency_chart_lenguage}" == "helm" ]]; then
                    chart_name="${initial_chart_name}"
                    local -a args=( \
                      "${dependency_name}" \
                      "${chart_name}" \
                      "${region_name}" \
                      "${cluster_name}" \
                      "${file_dependency}" \
                    )
                    # /$PLATFORM/helm-charts-configs/<dependency-name>/<[chart-name]>/<[region-name]>/<[cluster-name]>/*
                    case "${query_name}" in
                      # TODO:
                      #   - currently function does nothing.
                      # ./values.yaml
                      "hc-c-get-values")
                        funcHelmChartConfigsGetValues "${args[@]}"
                        ;;
                      "hc-c-update-versions-folder")
                        # TODO:
                        # - make sure the `bash main.sh g-clusters-file-put-to-latest-version`
                        #   is always executed first.`
                        funcHelmChartConfigsUpdateVersionsFolder "${args[@]}"
                        ;;
                      # /*
                      "hc-c-create-helm-chart")
                        funcHelmChartConfigsCreateChart "${args[@]}"
                        # funcHelmChartConfigsUpdateChartYamlFile "${args[@]}"
                        # funcHelmChartConfigsUpdateValuesAddDependencyNameAsProperty "${args[@]}"
                        ;;
                      "hc-c-create-_helpers-file")
                        funcHelmChartConfigs_HelpersFile "${args[@]}"
                        ;;
                      # ./Chart.yaml
                      "hc-c-update-chart-yaml-file")
                        funcHelmChartConfigsUpdateChartYamlFile "${args[@]}"
                        funcHelmChartConfigsUpdateValuesAddDependencyNameAsProperty "${args[@]}"
                        ;;
                      "hc-c-update-values-file-add-dependency-name-as-property")
                        funcHelmChartConfigsUpdateValuesAddDependencyNameAsProperty "${args[@]}"
                        ;;
                      # .<[ignore-file-name]>
                      "hc-c-update-ignore-file-helmignore")
                        local -a args_5=(".helmignore" "${args[@]}")
                        utilHelmChartConfigsUpdateIgnoreFiles "${args_5[@]}"
                        ;;
                      # ./
                      "hc-c-update-version")
                        # TODO: This should never be allow beyond dev clusters.
                        funcHelmChartConfigsUpdateVersion "${args[@]}"
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
              done < <(utilQueryClustersYaml "${args_2[@]}")
            done < <(utilQueryClustersYaml "${args_1[@]}")
          )
          # break
        done
      )
      # break
    done
  )
}
