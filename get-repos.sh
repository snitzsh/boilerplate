#!/bin/bash

# NOTE
# - boilerplate project is clone in this script. it should be clone manually.
#
# TODO:
# - Create flags/options to pass in when executing this script through cli
#

# TODO:
# - Save in secrets.
GITHUB_API_TOKEN=""
# TODO:
# - Save in secrets.
GITHUB_API_THROTTLE_INTEVAL=30000 # in seconds
# TODO:
# - Save in secrets.
GITHUB_DOMAIN="https://api.github.com"
# NOTE:
# - Gets the parent directory, ex: ../../../snitzh, not ../../../snitzh/boilerplate
# TODO:
# - Save in secrets.
SNITZSH_PATH=${PWD%/*}

#
# TODO:
#  - implement vervose output.
#
# NOTE:
#   - https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
#   - https://en.wikipedia.org/wiki/ANSI_escape_code
#     Black        0;30     Dark Gray     1;30
#     Red          0;31     Light Red     1;31
#     Green        0;32     Light Green   1;32
#     Brown/Orange 0;33     Yellow        1;33
#     Blue         0;34     Light Blue    1;34
#     Purple       0;35     Light Purple  1;35
#     Cyan         0;36     Light Cyan    1;36
#     Light Gray   0;37     White         1;37
#
# DESCRIPTION
#   - outputs stdout and stderr logs
#
# ARGS:
#   - $1 : level    : info | warn | error : type of log
#   - $2 : message  : any                 : error message
#   - $3 : source   : any                 : which function executed logger func
#
# RETURN
#   - STRING  : log
#   * example >
#   *   2023-06-11 11:16:40 - INFO - Removed 16 files - syncHelmModulesFileNames
#
function logger () {
  local _time
  _time=$(date -u +"%Y-%m-%d %T")
  local color="31"
  case $1 in
    "INFO")
      color="34"
      ;;

    "WARN")
      color="33"
      ;;

    "ERROR")
      color="31"
      ;;

    *)
      color="31"
      ;;
  esac
  echo -e "${_time} - \033[${color}m ${1} \033[0m - ${2} - ${3}"
}

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Creates folders recursebly to ensure it always exit without creating them
#     manually
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
createFolders () {
  local -r arr=(
    "apps"
    "helm-charts"
  )
  for folder in "${arr[@]}"; do
    mkdir -p "${SNITZSH_PATH}/$folder"
  done
}

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
        '(($current_timestamp | tonumber) - .timestamp) > ($trottle_interval | tonumber)' "${file_name}" \
    )
  else
    allow_api_request="true"
  fi

  if [ "${allow_api_request}" == true ]; then
    curl --request GET \
      --url "${GITHUB_DOMAIN}/${endpoint}${query_string}" \
      --header "Accept: application/vnd.github+json" \
      --header "Authorization: Bearer ${GITHUB_API_TOKEN}" \
      | jq --arg timestamp "${utc_timestamp}" '. | {"data": ., "timestamp": ($timestamp | tonumber) }' \
      > "${file_name}"
  else
    local -r timer=$(
      jq \
        --arg current_timestamp "${utc_timestamp}" \
        --arg trottle_interval "${GITHUB_API_THROTTLE_INTEVAL}" \
        '((($trottle_interval | tonumber) - (($current_timestamp | tonumber) - .timestamp)) / 60)' "${file_name}" \
    )
    logger "ERROR" "API /${endpoint}${query_string} has been requested already wait ${timer} minutes." "${func_name}"
  fi
}

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - clones repos
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
  while IFS='' read -r line; do repositories+=("$line"); done < <(
    jq -r '.data | .[] | .name' "${file_name}"
  )
  for repository in "${repositories[@]}"; do
    if [ "${repository}" == "boilerplate" ]; then
      continue
    fi
    if [[ "${repository}" == "helm-chart-"* ]];then
      local repository_dir="${SNITZSH_PATH}/helm-charts"
      if [ ! -d "${repository_dir}/${repository}" ]; then
        logger "INFO" "Cloning repository ${repository}..." "${func_name}"
        if git -C "${repository_dir}" \
            clone \
              --quiet \
              "git@github.com:snitzsh/${repository}.git" > /dev/null; then
          # Fetch
          ( \
            cd "${repository_dir}/${repository}" \
            && logger "INFO" "Fetching repository data..." "${func_name}" \
            && git fetch \
              --quiet \
              --all \
          )
        else
          logger "ERROR" "Failed clonning ${repository_dir}/${repository}." "${func_name}"
        fi
      else
        logger "WARNING" "Repository already exist in path: ${repository_dir}/${repository}." "${func_name}"
      fi
    fi
  done
}

main() {
  createFolders
  getRepositories
  cloneRepositories
}

main
