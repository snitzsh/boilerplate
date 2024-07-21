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
function utilQueryAwsResponses () {
  # local -r func_name="${FUNCNAME[0]}"
  local -ar args=("$@")
  local -r query_name="${args[0]}"
  local -r cloud_account="${args[1]}"
  local -r cloud_profile="${args[2]}"
  local -r cloud_region="${args[3]}"
  local -r sub_query_name="${args[4]}"
  local output_path_folder="${CACHE_PATH}"
  local api_file_name="${output_path_folder}/aws/${cloud_account}-${cloud_region}-${query_name}.json"

  local -a args_2=( \
    "${query_name}" \
    "${cloud_account}" \
    "${cloud_profile}" \
    "${cloud_region}" \
  )
  #
  # NOTE:
  #   - you must add the query here, even if no additional arguments are needed
  #   - Codes:
  #       -2  - query doesn't exits
  #       -1  - file not found.
  #       0   - success (same code as aws)
  #       254 - API return error (same code as aws) and/or file didn't get
  #             created due to api failue
  #       900 - unknown properties, maybe api response have different object)
  #       904 - item not found
  #
  case "${query_name}" in
    "secretsmanager-list-secrets")
      ;;
    "secretsmanager-get-secret-value")
      args_2+=( \
        "${args[5]}" \
      )
      ;;
    "secretsmanager-delete-secret")
      args_2+=( \
        "${args[5]}" \
      )
      ;;
    "secretsmanager-create-secret")
      args_2+=( \
        "${args[5]}" \
        "${args[6]}" \
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

  utilsAwsApis "${args_2[@]}"

  if [ ! -f "${api_file_name}" ]; then
    jq \
      -n \
      --arg api_file_name "${api_file_name}" \
      '
        {
          "sub_status": "-1",
          "status": "254",
          "data": {
            "message": ("File " + $api_file_name + " does not exist.")
          },
          "timestamp": null
        }
      '
  fi

  case "${sub_query_name}" in
    #
    # TODO:
    #   - Maybe we need to pass a flag to return all items or specific item.
    "secretsmanager-list-secrets-query-{secret}")
      local -r secret_name="${args[5]}"
      jq \
        -r \
        --arg secret_name "${secret_name}" \
        '
          .status as $status
          | .timestamp as $timestamp
          | if .status == "0" then
              .data
              | if type == "object" then
                  .SecretList
                  | if type == "array" then
                      [(.[] | select(.Name == $secret_name))] as $_data
                      | if ($_data | length) > 0 then
                          {
                            "sub_status": "0",
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
                          "message": "Property .SecretList not found and/or expected array datatype.",
                          "sub_status": "900"
                        },
                        "timestamp": $timestamp
                      }
                    end
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
                "sub_status": "254"
              } + .
            end
        ' "${api_file_name}"
      ;;
    "secretsmanager-get-secret-value")
      jq \
        -r \
        '
          .status as $status
          | .timestamp as $timestamp
          | if .status == "0" then
              .data
              | if type == "object" then
                  {
                    "sub_status": "0",
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
                "sub_status": "254"
              } + .
            end
        ' "${api_file_name}"
      ;;
    "secretsmanager-create-secret")
      jq \
        -r \
        '
          .status as $status
          | .timestamp as $timestamp
          | if .status == "0" then
              .data
              | if type == "object" then
                  {
                    "sub_status": "0",
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
                "sub_status": "254"
              } + .
            end
        ' "${api_file_name}"
      ;;
    "secretsmanager-delete-secret")
      jq \
        -r \
        '
          .status as $status
          | .timestamp as $timestamp
          | if .status == "0" then
              .data
              | if type == "object" then
                  {
                    "sub_status": "0",
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
                "sub_status": "254"
              } + .
            end
        ' "${api_file_name}"
      ;;
    *)
      jq \
        -n \
        -r \
        --arg sub_query_name "${sub_query_name}" \
        '
          {
            "sub_status": "-1",
            "status": "254",
            "data": {
              "message": ("sub-query " + $sub_query_name + " does not exist.")
            },
            "timestamp": null
          }
        '
      ;;
  esac
}
