#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - makes a curl request to get all the repos, places them in `../.cache`
#     folder
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
utilGetRepositories () {
  local -r func_name="${FUNCNAME[0]}"
  local -r utc_timestamp=$(date -u +%s)
  # local -r query_string="?per_page=1"
  local -r query_string=""
  local -r endpoint="user/repos"
  local -r file_name="${SNITZSH_PATH}/boilerplate/.cache/$(echo "${endpoint}" | tr '/' '-').json"
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
  echo "${GITHUB_API_TOKEN}"
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
          (
            ($trottle_interval | tonumber) - (($current_timestamp | tonumber) - .timestamp)
          ) / 60
        ' "${file_name}" \
    )
    logger "ERROR" "API /${endpoint}${query_string} has been requested already wait ${timer} minutes." "${func_name}"
  fi
}
