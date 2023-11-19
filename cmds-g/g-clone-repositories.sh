#!/bin/bash
# shellcheck source=/dev/null

# ------------------------------------------------------------------------------
# SCRIPT
# ------------------------------------------------------------------------------
# NOTE
#   - only the boilerplate repository MUST BE cloned manually!!!!
#
# TODO:
#   - Create flags/options to pass in when executing this script through cli
#   - Handle app* repositories
#
# DESCRIPTION:
# - This script will only clone what exits. It will not create a repo
#
# ------------------------------------------------------------------------------

source "${SNITZSH_PATH}/boilerplate/funcs-r/source-funcs.sh"
source "${SNITZSH_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - null
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
  local -r file_name="${SNITZSH_PATH}/boilerplate/.cache/$(echo "${endpoint}" | tr '/' '-').json"
  local -a repositories=()
  local -a helm_chart_dependencies=()
  local -r prefix_one="helm-chart"
  local -r prefix_two="app"
  local repository_dir=""

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
    # Helm Chart Repos
    if [[ "${repository}" == "${prefix_one}-"* ]]; then
      local repository_nickname=""
      local dependency_name=""
      local chart_name=""
      local found="false"
      repository_dir="${SNITZSH_PATH}/${prefix_one}s"
      for dependency in "${helm_chart_dependencies[@]}"; do
        chart_name=$(echo "${dependency}" | yq -r 'split("|") | .[1]')
        if [[ "${repository}" == *"${chart_name}" ]]; then
          repository_nickname="${chart_name}"
          dependency_name=$(echo "${dependency}" | yq -r 'split("|") | .[0]')
          found="true"
          break
        fi
      done
      if [ "${found}" == "true" ]; then
        local dependency_folder_name="${repository_dir}/${dependency_name}"
        # Creates folder for each dependency repository in ../../helm-charts folder
        mkdir -p "${dependency_folder_name}"
        local chart_name_folder_name="${dependency_folder_name}/${repository_nickname}"
        # Folder doesn't exist
        if [ ! -d "${chart_name_folder_name}" ]; then
          logger "INFO" "Cloning repository ${repository}..." "${func_name}"
          if git -C "${dependency_folder_name}" \
              clone \
                --quiet \
                "git@github.com:snitzsh/${repository}.git" "${repository_nickname}" > /dev/null; then
            # Fetch
            ( \
              cd "${chart_name_folder_name}" \
              && logger "INFO" "Fetching repository data..." "${func_name}" \
              && git fetch \
                --quiet \
                --all \
            )
          else
            logger "ERROR" "Failed clonning ${chart_name_folder_name}." "${func_name}"
          fi
        else
          logger "WARN" "Repository already exist in path: ${chart_name_folder_name}." "${func_name}"
        fi
      else
        logger "ERROR" "Repository '${repository}' is not found in '${SNITZSH_PATH}/boilerplate/helm-chart-dependencies.yaml' file." "${func_name}"
      fi
    # APP Repos
    elif [[ "${repository}" == "${prefix_two}-"* ]]; then
      local repository_dir="${SNITZSH_PATH}/${prefix_two}s"
      if [ ! -d "${repository_dir}/${dependency_name}/${repository_nickname}" ]; then
        logger "INFO" "Cloning repository ${repository}..." "${func_name}"
      fi
      # TODO: do the APP Repos
    fi
  done
}

main() {
  utilCreateFolders
  utilGetRepositories
  cloneRepositories
}

main
