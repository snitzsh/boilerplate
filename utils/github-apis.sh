#!/bin/bash

#
# TODO:
#   - support pagination, for `list` apis
#
# NOTE:
#   - if a cached response already exist and doesn't have .timestamp then it
#     will create a new api.
#   - x404 is consider if an item is not found. where as 400 is when resource is
#     not found.
#   - DO NOT add echo in this function, because it will not return a valid json.
#
# DESCRIPTION:
#   - null
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#

function utilsGithubApis () {
  local -r func_name="${FUNCNAME[0]}"
  local -ar args=("$@")
  local -r query_name="${args[0]}"
  local -r utc_timestamp=$(date -u +%s)
  local output_path_folder="${CACHE_PATH}"
  # Creates folder if doesn't exist.
  mkdir -p "${output_path_folder}/github"
  # NOTE
  #  - jq doesn't have in-place command. So the work around is use `_<[file]>.json`
  local curl_output_file="${output_path_folder}/github/_${query_name}.json"
  local api_file_name="${output_path_folder}/github/${query_name}.json"
  # rm -rf "${curl_output_file}"
  if [ -f "${api_file_name}" ]; then
    rm "${api_file_name}"
  fi
  local allow_api_request="false"

  # NOTE:
  # - 200 GET
  # - 201 POST
  # - 204 DELETE
  # - 304 POST GET DELETE
  local -ar no_skip_cache_status_codes=( \
    "200" \
    "201" \
    "204" \
    "304" \
  )

  if [ -f "${api_file_name}" ]; then
    allow_api_request=$( \
      jq \
        -r \
        --arg current_timestamp "${utc_timestamp}" \
        --arg trottle_interval "${GITHUB_API_THROTTLE_INTEVAL}" \
        --arg no_skip_cache_status_code "${no_skip_cache_status_codes[*]}" \
        '
          ($no_skip_cache_status_code | split(" ")) as $status_codes
          | if .timestamp == null or .data == null then
              true
            else
              .status as $status
              | (($current_timestamp | tonumber) - .timestamp) > ($trottle_interval | tonumber)
              | if (. == false) and (($status_codes | index($status)) == null) then
                  true
                end
            end
        ' "${api_file_name}" \
    )
  else
    allow_api_request="true"
  fi

  local status=""

  if [ "${allow_api_request}" == "true" ]; then
    case "${query_name}" in
      "get-user-repos")
        status=$( \
          curl \
            -L \
            -s \
            --request GET \
            -w "%{http_code}" \
            -o "${curl_output_file}" \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            --header "Authorization: Bearer ${GITHUB_API_TOKEN}" \
            --url "${GITHUB_DOMAIN}/user/repos${query_string}" \
        )
        ;;
      #
      # DOCS:
      #   - https://docs.github.com/en/rest/users/keys?apiVersion=2022-11-28
      #
      # NOTE:
      #   - `-s` prevent returning curl metrics on stdout
      #
      "get-user-keys")
        local -r query_string="?per_page=100"
        status=$( \
          curl \
            -L \
            -s \
            --request GET \
            -w "%{http_code}" \
            -o "${curl_output_file}" \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            -H "Authorization: Bearer ${GITHUB_API_TOKEN}" \
            --url "${GITHUB_DOMAIN}/user/keys${query_string}" \
        )
        ;;
      "create-user-keys")
        local -r secret_name="${args[1]}"
        local -r public_key="${args[2]}"
        status=$( \
          curl \
            -L \
            -s \
            --request POST \
            -w "%{http_code}" \
            -o "${curl_output_file}" \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            -H "Authorization: Bearer ${GITHUB_API_TOKEN}" "${GITHUB_DOMAIN}/user/keys" \
            -d "{\"title\": \"$secret_name\", \"key\": \"$public_key\"}" \
        )
        ;;
      "delete-user-keys")
        #
        # NOTE:
        #   - /DELETE do not return body, instead it only returns code. So it
        #     must be handle differently so we can write a consistent file.
        #
        local -r key_id="${args[1]}"
        status=$( \
          curl \
            -L \
            -s \
            -X DELETE \
            -w "%{http_code}" \
            -o "/dev/null" \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            -H "Authorization: Bearer ${GITHUB_API_TOKEN}" \
            --url "${GITHUB_DOMAIN}/user/keys/${key_id}" \
        )
        jq \
          -n \
          --arg status "${status}" \
          '
            {}
          ' > "${curl_output_file}"
        ;;
      *)
        ;;
    esac

    # Handler of all api responses.
    jq \
      --arg timestamp "${utc_timestamp}" \
      --arg status "${status}" \
      '
        {
          "data": .,
          "status": $status,
          "timestamp": ($timestamp | tonumber)
        }
      ' "${curl_output_file}" > "${api_file_name}"

  # else
    # local -r timer=$(
    #   jq \
    #     --arg current_timestamp "${utc_timestamp}" \
    #     --arg trottle_interval "${GITHUB_API_THROTTLE_INTEVAL}" \
    #     '
    #       (
    #         ($trottle_interval | tonumber) - (($current_timestamp | tonumber) - .timestamp)
    #       ) / 60
    #     ' "${api_file_name}" \
    # )
    # logger "ERROR" "API /${query_name} has been requested already wait ${timer} minutes." "${func_name}"
  fi
  #
  # NOTE
  # - jq doesn't allow you to update the file like yq -ri this is the work
  #   around.
  #
  if [ -f "${curl_output_file}" ]; then
    rm "${curl_output_file}"
  fi
}
