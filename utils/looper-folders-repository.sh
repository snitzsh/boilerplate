#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - loops to all folders to make sure all repositories follows same rules
#
# DESCRIPTION:
#   - loops to all folders to make sure all repositories follows same rules
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function utilLooperFoldersRepositories () {
  local -r func_name="${FUNCNAME[0]}"
  local -ar args=("$@")
  local -r query_name="${args[0]}"
  local -r folder_name="${args[1]}"
  # local -r arg_dependency_name="${args[2]}"
  # contexts: chart_name or app_name
  (
    cd "${PLATFORM_PATH}/${folder_name}" &&
    for dependency_name in *; do
      # local initial_chart_name=""
      # # if-statement for testing purposes
      # if [ "${dependency_name}" != "snitzsh" ]; then
      #   continue
      # fi
      (
        cd "./${dependency_name}" &&
        case "${folder_name}" in
          "apis")
            ;;
          "helm-charts" | "helm-charts-configs")
            for chart_name in *; do
              initial_chart_name="${chart_name}"
              (
                cd "./${chart_name}" &&
                case "${query_name}" in
                  "r-update-gitignore-file")
                    local -a args_2=( \
                      '.gitignore' \
                      "${dependency_name}" \
                      "${chart_name}" \
                      "null" \
                      "null" \
                      "null" \
                      "${initial_chart_name}" \
                    )
                    utilHelmChartConfigsUpdateIgnoreFiles "${args_2[@]}"
                    ;;
                  "r-create-git-hooks")
                    # TODO:
                    # - make sure you run `bash main.sh hc-update-helmignore-file`
                    #   after it executes this function.
                    # funcRepositoryCreateGitHooks "${args_2[@]}"
                    ;;
                  *)
                    ;;
                esac
              )
              # break
            done
            ;;
          "mobiles")
            ;;
          "scripts")
            ;;
          "uis")
            ;;
          *)
            logger "ERROR" "Folder name ${folder_name} not found." "${func_name}"
            ;;
        esac
      )
      # break
    done
  )
}
