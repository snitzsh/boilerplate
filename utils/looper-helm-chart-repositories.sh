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
  local -r query_name="${1}"
  local -a regions_name_arr=()
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
      (
        cd "./${dependency_name}" &&
        for chart_name in *; do
          (
            cd "./${chart_name}" &&
            case "${query_name}" in
              "update-ignore-file-gitignore")
                local -a args_6=( \
                  '.gitignore' \
                  "${dependency_name}" \
                  "${chart_name}" \
                )
                utilHelmChartUpdateIgnoreFile "${args_6[@]}"
                ;;
              *)
                ;;
            esac
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
                # TODO:
                #   - should only run for north-america dev
                # NOTE:
                #   - Just runs if .helm_clusters is null.
                local -a args_3=( \
                  "post-{region_name}-{cluster-name}-helm-charts-dependencies" \
                  "${region_name}" \
                  "${cluster_name}" \
                )
                utilQueryClustersYaml "${args_3[@]}"
                sleep 1 # I/O Issues, needs timeout.
                # sub-shell
                mkdir -p ./"${region_name}/${cluster_name}"
                (
                  cd "./${region_name}/${cluster_name}" &&
                  # TODO:
                  # - Update cluster file and before updating the chart.
                  # - Dev on each region by default should put the latest.
                  #   sit -> uat -> prod should get in steps. Ex. sit should get the dev dependencies by default (if doesn't exist)
                  local -a args_4=( \
                    "get-{region_name}-{cluster-name}-helm-charts-{dependency_name}-{chart_name}" \
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
                    # /snitzsh/helm-charts/<dependency-name>/<[chart-name]>/<[region-name]>/<[cluster-name]>/*
                    case "${query_name}" in
                      # TODO: currently function does nothing.
                      # ./values.yaml
                      "get-values")
                        funcHelmChartGetValues "${args[@]}"
                        ;;
                      # /*
                      "post-helm-chart")
                        funcHelmChartPostChart "${args[@]}"
                        ;;
                      # ./Chart.yaml
                      "update-chart-yaml-file")
                        funcHelmChartUpdateChartYamlFile "${args[@]}"
                        ;;
                      # .<[ignore-file-name]>
                      "update-ignore-file-helmignore")
                        local -a args_5=('.helmignore' "${args[@]}")
                        utilHelmChartUpdateIgnoreFile "${args_5[@]}"
                        ;;
                      # ./
                      "update-version")
                        # TODO: This should never be allow beyond dev clusters.
                        funcHelmChartUpdateVersion "${args[@]}"
                        ;;
                      *)
                        # echo "Function query does not exist."
                        ;;
                    esac
                  else
                    logger "ERROR" "Chart '${chart_name}' for dependency: '${dependency_name}' is not found in './helm-charts-dependencies.yaml'. Possible issues: 1) Make sure the repository name cloned follows the naming-convention. 2) Chart has been depricated from the helm-charts-dependencies.yaml and still have the repository cloned." "${func_name}"
                  fi
                )
              done
            done
          )
          break
        done
      )
      break
    done
  )
}
