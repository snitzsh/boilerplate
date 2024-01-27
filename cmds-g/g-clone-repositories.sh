#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - Create flags/options to pass in when executing this script through cli.
#
# NOTE
#   - only the boilerplate repository MUST BE cloned manually!!!!
#
#
# DESCRIPTION:
# - This script will only clone what exits. It will not create a repo
#
#

source "${PLATFORM_PATH}/boilerplate/funcs-r/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - remove duplicate code.
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - clones repos, i
#
# ARGS:
#   - $1 - repos - array
#
# RETURN:
#   - null
#
cloneRepositories() {
  local -r func_name="${FUNCNAME[0]}"
  local -r endpoint="user/repos"
  local -r file_name="${PLATFORM_PATH}/boilerplate/.cache/$(echo "${endpoint}" | tr '/' '-').json"
  local -a repositories=()
  local -a helm_chart_dependencies=()
  local -a apps="${APPS}"
  # TODO:
  #   - use REPOSITORY_NAME_IDS
  #   - instead of doing a variable per prefix create an array
  #   - auto generate regex when looping instead of manually adding...
  #   - figure out a good pattern for different apps ex: ui-juan-rust.
  #     (That would be cool)
  # local -ar repos_prefixes=( \
  #   '^helm-chart-.*$' \
  #   '^helm-chart-.*-configs$' \
  #   '^apis-.*$' \
  #   '^ui-.*$' \
  #   '^process-.*$' \
  # )
  local -r prefix_1='^helm-chart-.*$'
  local -r prefix_2='^helm-chart-.*-configs$'
  local -r prefix_3='^api-.*$'
  local -r prefix_4='^ui-.*$'
  local -r prefix_5='^process-.*$'
  local -r prefix_6='^mobile-.*$'
  local -r prefix_7='^script-.*$'

  local folder_name_level_1=""

  while IFS='' read -r line; do repositories+=("$line"); done < <(
    jq -r '.data | .[] | .name' "${file_name}"
  )

  while IFS='' read -r line; do helm_chart_dependencies+=("$line"); done < <(
    utilGetHelmChartDependecies | yq -r -o=json 'split(" ")' | jq -r '.[]'
  )

  for repository in "${repositories[@]}"; do
    if [ "${repository}" == "boilerplate" ] ; then
      continue
    fi

    local repository_nickname=""
    local dependency_name=""
    local chart_name=""
    local found="false"
    local folder_name_level_2=""
    local chart_name_folder_name=""
    local args_2=()
    # helm-charts
    if [[ "${repository}" =~ $prefix_1 && ! "${repository}" =~ -configs$ ]]; then

      folder_name_level_1="${PLATFORM_PATH}/helm-charts"

      IFS=',' read -ra apps_array <<< "${apps}"
      for app_name in "${apps_array[@]}"; do
        args_2=(
          "g-clone-repositories-get-repository-last-word"
          "${app_name}"
          "${repository}"
        )
        repository_nickname=$(utilQueryRegexer "${args_2[@]}")
        if [ "${repository_nickname}" != "false" ]; then
          dependency_name="${app_name}"
          found="true"
          folder_name_level_2="${folder_name_level_1}/${dependency_name}"
          chart_name_folder_name="${folder_name_level_2}/${repository_nickname}"
          break
        fi
      done
    # helm-chart-...-configs
    elif [[ "${repository}" =~ $prefix_2 ]]; then
      folder_name_level_1="${PLATFORM_PATH}/helm-charts-configs"
      for dependency in "${helm_chart_dependencies[@]}"; do
        chart_name=$(echo "${dependency}" | yq -r 'split("|") | .[1]')
        if [[ "${repository}" == *"${chart_name}-configs" ]]; then
          repository_nickname="${chart_name}"
          dependency_name=$(echo "${dependency}" | yq -r 'split("|") | .[0]')
          found="true"
          folder_name_level_2="${folder_name_level_1}/${dependency_name}"
          chart_name_folder_name="${folder_name_level_2}/${repository_nickname}"
          break
        fi
      done

      if [ "${found}" == "false" ]; then
        logger "ERROR" "Repository '${repository}' is not found in '${PLATFORM_PATH}/boilerplate/hc-c-dependencies.yaml' file. Make sure .name is properly align with repository name convention." "${func_name}"
      fi
    # apis
    elif [[ "${repository}" =~ $prefix_3 ]]; then
      folder_name_level_1="${PLATFORM_PATH}/apis"
      IFS=',' read -ra apps_array <<< "${apps}"
      for app_name in "${apps_array[@]}"; do
        args_2=(
          "g-clone-repositories-get-repository-last-word"
          "${app_name}"
          "${repository}"
        )
        repository_nickname=$(utilQueryRegexer "${args_2[@]}")
        if [ "${repository_nickname}" != "false" ]; then
          dependency_name="${app_name}"
          found="true"
          folder_name_level_2="${folder_name_level_1}/${dependency_name}"
          chart_name_folder_name="${folder_name_level_2}/${repository_nickname}"
          break
        fi
      done
    # uis
    elif [[ "${repository}" =~ $prefix_4 ]]; then
      folder_name_level_1="${PLATFORM_PATH}/uis"
      IFS=',' read -ra apps_array <<< "${apps}"
      for app_name in "${apps_array[@]}"; do
        args_2=(
          "g-clone-repositories-get-repository-last-word"
          "${app_name}"
          "${repository}"
        )
        repository_nickname=$(utilQueryRegexer "${args_2[@]}")
        if [ "${repository_nickname}" != "false" ]; then
          dependency_name="${app_name}"
          found="true"
          folder_name_level_2="${folder_name_level_1}/${dependency_name}"
          chart_name_folder_name="${folder_name_level_2}/${repository_nickname}"
          break
        fi
      done
    # processes
    elif [[ "${repository}" =~ $prefix_5 ]]; then
      folder_name_level_1="${PLATFORM_PATH}/processes"
      IFS=',' read -ra apps_array <<< "${apps}"
      for app_name in "${apps_array[@]}"; do
        args_2=(
          "g-clone-repositories-get-repository-last-word"
          "${app_name}"
          "${repository}"
        )
        repository_nickname=$(utilQueryRegexer "${args_2[@]}")
        if [ "${repository_nickname}" != "false" ]; then
          dependency_name="${app_name}"
          found="true"
          folder_name_level_2="${folder_name_level_1}/${dependency_name}"
          chart_name_folder_name="${folder_name_level_2}/${repository_nickname}"
          break
        fi
      done
    # mobiles
    elif [[ "${repository}" =~ $prefix_6 ]]; then
      folder_name_level_1="${PLATFORM_PATH}/mobiles"
      IFS=',' read -ra apps_array <<< "${apps}"
      for app_name in "${apps_array[@]}"; do
        args_2=(
          "g-clone-repositories-get-repository-last-word"
          "${app_name}"
          "${repository}"
        )
        repository_nickname=$(utilQueryRegexer "${args_2[@]}")
        if [ "${repository_nickname}" != "false" ]; then
          dependency_name="${app_name}"
          found="true"
          folder_name_level_2="${folder_name_level_1}/${dependency_name}"
          chart_name_folder_name="${folder_name_level_2}/${repository_nickname}"
          break
        fi
      done
    # scripts
    elif [[ "${repository}" =~ $prefix_7 ]]; then
      folder_name_level_1="${PLATFORM_PATH}/scripts"
      IFS=',' read -ra apps_array <<< "${apps}"
      for app_name in "${apps_array[@]}"; do
        args_2=(
          "g-clone-repositories-get-repository-last-word"
          "${app_name}"
          "${repository}"
        )
        repository_nickname=$(utilQueryRegexer "${args_2[@]}")
        if [ "${repository_nickname}" != "false" ]; then
          dependency_name="${app_name}"
          found="true"
          folder_name_level_2="${folder_name_level_1}/${dependency_name}"
          chart_name_folder_name="${folder_name_level_2}/${repository_nickname}"
          break
        fi
      done
    # Unknown
    else
      # Other repos that with unknow prefix.
      found="false"
    fi

    if [ "${found}" == "true" ]; then
      # Creates folder for each dependency repository in ../../$REPOSITORY_NAME_IDS* folder
      mkdir -p "${folder_name_level_2}"

      # Folder doesn't exist
      if [ ! -d "${chart_name_folder_name}" ]; then
        logger "INFO" "Cloning repository ${repository}..." "${func_name}"
        if git -C "${folder_name_level_2}" \
            clone \
              --quiet \
              "${SSH_REPOSITORY_ENDPOINT}/${repository}.git" "${repository_nickname}" > /dev/null; then
          # Fetch
          (
            cd "${chart_name_folder_name}" \
            && logger "INFO" "Fetching repository data..." "${func_name}" \
            && git fetch \
              --quiet \
              --all \
            && sleep 1
          )
        else
          logger "ERROR" "Failed clonning ${chart_name_folder_name}." "${func_name}"
        fi
      else
        logger "WARN" "Repository already exist in path: ${chart_name_folder_name}." "${func_name}"
      fi
    fi

  done
}

main() {
  utilCreateFolders
  utilGetRepositories
  cloneRepositories
}

main
