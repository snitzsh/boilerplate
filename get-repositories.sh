#!/bin/bash
# shellcheck source=/dev/null

# NOTE
# - boilerplate repository MUST BE cloned manually!!!!
#
# TODO:
# - Create flags/options to pass in when executing this script through cli
#
# DESCRIPTION:
# - This script will only clone what exits. It will not create a repo
#

source "${SNITZSH_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - makes a curl request to get all the repos
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
getRepositories () {
  local -r func_name="${FUNCNAME[0]}"
  local -r utc_timestamp=$(date -u +%s)
  # local -r query_string="?per_page=1"
  local -r query_string=""
  local -r endpoint="user/repos"
  local -r file_name=".cache/$(echo "${endpoint}" | tr '/' '-').json"
  local allow_api_request="false"

  if [ -f "$file_name" ]; then
    allow_api_request=$(\
      jq \
        --arg current_timestamp "${utc_timestamp}" \
        --arg trottle_interval "${GITHUB_API_THROTTLE_INTEVAL}" \
        '
          (($current_timestamp | tonumber) - .timestamp) > ($trottle_interval | tonumber)
        ' "${file_name}" \
    )
  else
    allow_api_request="true"
  fi

  if [ "${allow_api_request}" == true ]; then
    curl \
      --silent \
      --request GET \
      --url "${GITHUB_DOMAIN}/${endpoint}${query_string}" \
      --header "Accept: application/vnd.github+json" \
      --header "Authorization: Bearer ${GITHUB_API_TOKEN}" \
      | jq \
        --arg timestamp "${utc_timestamp}" \
        '. | {"data": ., "timestamp": ($timestamp | tonumber) }' \
      > "${file_name}"
  else
    local -r timer=$(
      jq \
        --arg current_timestamp "${utc_timestamp}" \
        --arg trottle_interval "${GITHUB_API_THROTTLE_INTEVAL}" \
        '
          ((($trottle_interval | tonumber) - (($current_timestamp
          | tonumber) - .timestamp)) / 60)
        ' "${file_name}" \
    )
    logger "ERROR" "API /${endpoint}${query_string} has been requested already wait ${timer} minutes." "${func_name}"
  fi
}

getHelmChartDependecies () {
  local -a arr=()
  local -r helm_charts_dependcies_path="${SNITZSH_PATH}/boilerplate/helm-chart-dependencies.yaml"
  while IFS='' read -r line; do arr+=("$line"); done < <(
    # yq doesn't have an easy way to return a bash array. So using jq is the
    # easiest way.
    yq -o=json '
      [
        .dependencies[]
        | {"dependency": .name, "chart": (.charts[].name)}
        | .dependency + "." + .chart
      ]
    ' "${helm_charts_dependcies_path}" | jq -r '.[]'
  )
  echo "${arr[@]}"
}

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
  local -r file_name=".cache/$(echo "${endpoint}" | tr '/' '-').json"
  local repositories=()
  local -a helm_chart_dependencies=()
  local -r prefix_one="helm-chart"
  local -r prefix_two="app"
  local repository_dir=""

  while IFS='' read -r line; do repositories+=("$line"); done < <(
    jq -r '.data | .[] | .name' "${file_name}"
  )

  while IFS='' read -r line; do helm_chart_dependencies+=("$line"); done < <(
    getHelmChartDependecies | yq -r -o=json 'split(" ")' | jq -r '.[]'
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
        chart_name=$(echo "${dependency}" | yq -r 'split(".") | .[1]')
        if [[ "${repository}" == *"${chart_name}" ]]; then
          repository_nickname="${chart_name}"
          dependency_name=$(echo "${dependency}" | yq -r 'split(".") | .[0]')
          found="true"
          break
        fi
      done
      if [ "${found}" == "true" ]; then
        local dependency_folder_name="${repository_dir}/${dependency_name}"
        mkdir -p "${dependency_folder_name}"
        local chart_name_folder_name="${dependency_folder_name}/${repository_nickname}"
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
  createFolders
  getRepositories
  cloneRepositories
}

main
