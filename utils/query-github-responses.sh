#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - null
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
function utilQueryGithubResponses () {
  # local -r func_name="${FUNCNAME[0]}"
  local -ar args=("$@")
  local -r query_name="${args[0]}"
  local -r sub_query_name="${args[1]}"
  local output_path_folder="${CACHE_PATH}"
  local api_file_name="${output_path_folder}/github/${query_name}.json"

  local -a args_2=( \
    "${query_name}" \
  )

  case "${query_name}" in
    "get-user-repos")
      ;;
    "get-user-keys")
      ;;
    "create-user-keys")
      args_2+=( \
        "${args[2]}" \
        "${args[3]}" \
      )
      ;;
    "delete-user-keys")
      args_2+=( \
        "${args[2]}" \
      )
    ;;
    *)
      jq \
        -n \
        -r \
        --arg query_name "${query_name}" \
        '
          {
            "sub_status": "-2",
            "status": "254",
            "data": {
              "message": ("sub query " + $query_name + " does not exist.")
            },
            "timestamp": null
          }
        '
      exit 1
    ;;
  esac

  utilsGithubApis "${args_2[@]}"
  #
  # NOTE:
  #   - Codes:
  #       [github stauts codes] -  https://docs.github.com/en/rest/users/keys?apiVersion=2022-11-28
  #       900                   - unknown properties, maybe api response have different object)
  #       904                   - item not found
  #       905                   - multiple items with the same name. ssh_key
  #
  if [ ! -f "${api_file_name}" ]; then
    jq \
      -n \
      --arg api_file_name "${api_file_name}" \
      '
        {
          "sub_status": "-1",
          "status": "500",
          "data": {
            "message": ("File " + $api_file_name + " does not exist.")
          },
          "timestamp": null
        }
      '
  fi

  case "${sub_query_name}" in
    #
    # TODO
    #   - In git you can create multiple ssh with same title, to stay safe
    #     if there are multiple keys with same title, it returns the lastest key
    #     created. Figure out how we can delete multiple keys with same name.
    #     Maybe we will need to delete duplicated keys before attempting to
    #     create a new ssh-key.
    #
    "get-user-keys-query-{key}")
      local -r secret_name="${args[2]}"
      jq \
        --arg secret_name "${secret_name}" \
        '
          .status as $status
          | .timestamp as $timestamp
          | if .status == "200" then
              .data
              | if type == "array" then
                  ([(.[] | select(.title == $secret_name))]) as $_data
                  | if ($_data | length) > 0 then
                      {
                        "sub_status": "200",
                        "status": $status,
                        "data": $_data,
                        "timestamp": $timestamp
                      }
                    else
                      {
                        "sub_status": "904",
                        "status": $status,
                        "data": {
                          "message": ("Secret " + $secret_name + " not found."),
                          "sub_status": "904"
                        },
                        "timestamp": $timestamp
                      }
                    end
                else
                  {
                    "sub_status": "900",
                    "status": $status,
                    "data": {
                      "message": "Property .data not found and/or expected array datatype.",
                      "sub_status": "900"
                    },
                    "timestamp": $timestamp
                  }
                end
            else
              {
                "sub_status": $status,
              } + .
            end
        ' "${api_file_name}"
      ;;
    "create-user-keys")
      jq \
        -r \
        '
          .status as $status
          | .timestamp as $timestamp
          | if .status == "201" then
              .data
              | if type == "object" then
                  {
                    "sub_status": "201",
                    "status": $status,
                    "data": .,
                    "timestamp": $timestamp
                  }
                else
                  {
                    "sub_status": "900",
                    "status": $status,
                    "data": {
                      "message": "Property .data not found and/or expected object datatype.",
                      "sub_status": "900"
                    },
                    "timestamp": $timestamp
                  }
                end
            else
              {
                "sub_status": $status,
              } + .
            end
        ' "${api_file_name}"
      ;;
      "delete-user-keys")
        jq \
          -r \
          '
            .status as $status
            | .timestamp as $timestamp
            | if .status == "204" then
                .data
                | if type == "object" then
                    {
                      "sub_status": "204",
                      "status": $status,
                      "data": .,
                      "timestamp": $timestamp
                    }
                  else
                    {
                      "sub_status": "900",
                      "status": $status,
                      "data": {
                        "message": "Property .data not found and/or expected object datatype.",
                        "sub_status": "900"
                      },
                      "timestamp": $timestamp
                    }
                  end
              else
                {
                  "sub_status": $status,
                } + .
              end
          ' "${api_file_name}"
        ;;
    *)
      ;;
  esac
}
