#!/bin/bash

#
# TODO:
#   - check if system support ed25519, else do this: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
#
# NOTE:
#   - if minikube, it will default to aws
#   - secret source of truth is cloud
#       - if secret doesn't exist in cloud, it creates a ssh-key locally then
#         upload to cloud (aws) and github
#       - if secret exist, it will donwload and match or upload the key to
#         github. if it does not match script will exit.
#   - For testing, if you generate a secret with a dummy-name, make sure remove
#     it from the cloud and github.
#
# DESCRIPTION:
#   - Deletes AWS eks cluster.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function clusterArgoCDSshKey () {
  local -r func_name="${FUNCNAME[0]}"
  local -ar args=("$@")
  # Region Name is not the region of aws!
  local -r cluster_type="${args[0]}"
  local -r region_name="${args[1]}"
  local -r cluster_name="${args[2]}"
  # local -r dependency_name="${args[3]}"
  # local -r chart_name="${args[4]}"
  local -r cluster_configs="${args[5]}"
  local cloud_name=""
  local cloud_region=""
  local cloud_profile=""

  local -ar args_1=( \
    "read-{region_name}-{cluster_name}-configs-prop" \
    "${cluster_configs}" \
    "account" \
  )
  cloud_account=$(utilQueryClustersYaml "${args_1[@]}")

  local -ar args_2=( \
    "read-{region_name}-{cluster_name}-configs-prop" \
    "${cluster_configs}" \
    "cloud" \
  )
  cloud_name=$(utilQueryClustersYaml "${args_2[@]}")

  local -ar args_3=( \
    "read-{region_name}-{cluster_name}-configs-prop" \
    "${cluster_configs}" \
    "profile" \
  )
  cloud_profile=$(utilQueryClustersYaml "${args_3[@]}")

  local -ar args_4=( \
    "read-{region_name}-{cluster_name}-configs-prop" \
    "${cluster_configs}" \
    "region" \
  )
  cloud_region=$(utilQueryClustersYaml "${args_4[@]}")

  if [ "${cluster_type}" == "minikube" ]; then
    cloud_name="aws"
  fi

  local -r secret_file_name="local"
  local -r secret_name="${region_name}/${cluster_name}/argo/argo-cd"
  local -r secret_name_path="${CLUSTER_SSH_KEY_PATH}/${secret_name}"
  logger "INFO" "SSH folder location: ${secret_name_path}" "${func_name}"
  case "${cloud_name}" in
    "aws")
        # Creates folder if don't exist
        mkdir -p "${secret_name_path}"

        # Foces delete to test again.
        # local -ar args_10=( \
        #   "secretsmanager-delete-secret" \
        #   "${cloud_account}" \
        #   "${cloud_profile}" \
        #   "${cloud_region}" \
        #   "secretsmanager-delete-secret" \
        #   "${secret_name}" \
        # )
        # utilQueryAwsResponses "${args_10[@]}"

        # NOTE:
        #   - Needed it to give time to SecretManager Deletion Scheduled. Nothing
        #     we can do for now
        #
        # sleep 30

        # AWS api
        local -ar args_5=( \
          "secretsmanager-list-secrets" \
          "${cloud_account}" \
          "${cloud_profile}" \
          "${cloud_region}" \
          "secretsmanager-list-secrets-query-{secret}" \
          "${secret_name}" \
        )
        # AWS List Secrets
        local cloud_list_secrets_query_secret_res=""
        cloud_list_secrets_query_secret_res=$(utilQueryAwsResponses "${args_5[@]}")
        # AWS List Secrets status
        local -r cloud_list_secrets_query_secret_res_status=$( \
          jq \
            -n \
            -r \
            --argjson api_response "${cloud_list_secrets_query_secret_res}" \
            '
              $api_response
              | .status
            '
        )
        # AWS List Secrets sub-status
        local -r cloud_list_secrets_query_secret_res_sub_status=$( \
          jq \
            -n \
            -r \
            --argjson api_response "${cloud_list_secrets_query_secret_res}" \
            '
              $api_response
              | .sub_status
            '
        )
        # AWS List Secrets arn. AWS cannot have mutiple keys with same name.
        local -r cloud_list_secrets_query_secret_res_arn=$( \
          jq \
            -n \
            -r \
            --argjson api_response "${cloud_list_secrets_query_secret_res}" \
            '
              $api_response
              | if .sub_status != "904" then
                  .data[].ARN
                end
            '
        )
        if [ "${cloud_list_secrets_query_secret_res_status}" == "0" ] && [ "${cloud_list_secrets_query_secret_res_sub_status}" == "0" ]; then
          local -ar args_6=( \
            "secretsmanager-get-secret-value" \
            "${cloud_account}" \
            "${cloud_profile}" \
            "${cloud_region}" \
            "secretsmanager-get-secret-value" \
            "${cloud_list_secrets_query_secret_res_arn}" \
          )
          # AWS Secret
          local cloud_get_secret_value_res
          cloud_get_secret_value_res=$(utilQueryAwsResponses "${args_6[@]}")
          # AWS Secret status
          local -r cloud_get_secret_value_res_status=$( \
            jq \
              -n \
              -r \
              --argjson api_response "${cloud_get_secret_value_res}" \
              '
                $api_response
                | .status
              '
          )
          # AWS Secret sub-status
          local -r cloud_get_secret_value_res_sub_status=$( \
            jq \
              -n \
              -r \
              --argjson api_response "${cloud_get_secret_value_res}" \
              '
                $api_response
                | .sub_status
              '
          )
          if [ "${cloud_get_secret_value_res_status}" == "0" ] && [ "${cloud_get_secret_value_res_sub_status}" == "0" ]; then
            # Gets re-assigned for clear if-statement flow.
            cloud_list_secrets_query_secret_res="${cloud_get_secret_value_res}"
          else
            local -r cloud_get_secret_value_res_error_message=$( \
              jq \
                -n \
                -r \
                --argjson api_response "${cloud_get_secret_value_res}" \
                '
                  $api_response
                  | .data.message
                '
            )
            logger "ERROR" "Status: ${cloud_get_secret_value_res_status} | Sub-status: ${cloud_get_secret_value_res_sub_status} | ${cloud_get_secret_value_res_error_message}" "${func_name}"
            exit 1
          fi
        else
          # If not found, it means that we need to upload one
          if [ "$cloud_list_secrets_query_secret_res_sub_status" != "904" ]; then
            local -r cloud_list_secrets_query_secret_res_error_message=$( \
              jq \
                -n \
                -r \
                --argjson api_response "${cloud_list_secrets_query_secret_res}" \
                '
                  $api_response
                  | .data.message
                '
            )
            logger "ERROR" "AWS | Status: ${cloud_list_secrets_query_secret_res_status} | Sub-status: ${cloud_list_secrets_query_secret_res_sub_status} | ${cloud_list_secrets_query_secret_res_error_message}" "${func_name}"
            exit 1
          fi
        fi

        # Github api
        local -ar args_7=( \
          "get-user-keys" \
          "get-user-keys-query-{key}"
          "${secret_name}" \
        )
        local -r github_key_query_key_res=$(utilQueryGithubResponses "${args_7[@]}")
        # Github api status
        local -r github_get_user_keys_query_key_status=$( \
          jq \
            -n \
            -r \
            --argjson api_response "${github_key_query_key_res}" \
            '
              $api_response
              | .status
            '
        )
        # Github api sub-status
        local -r github_get_user_keys_query_key_sub_status=$( \
          jq \
            -n \
            -r \
            --argjson api_response "${github_key_query_key_res}" \
            '
              $api_response
              | .sub_status
            '
        )
        # Githib api error-message
        local -r github_get_user_keys_error_message=$( \
          jq \
            -n \
            -r \
            --argjson api_response "${github_key_query_key_res}" \
            '
              $api_response
              | if .status != "200" and .sub_status != "200" then
                  .data.message
                end
            '
        )

        if [ "${github_get_user_keys_query_key_status}" != "200" ] || { [ "${github_get_user_keys_query_key_sub_status}" != "200" ] && [ "${github_get_user_keys_query_key_sub_status}" != "904" ]; }; then
          logger "ERROR" "Github | Status: ${github_get_user_keys_query_key_status} | Sub-status: ${github_get_user_keys_query_key_sub_status} | ${github_get_user_keys_error_message}" "${func_name}"
          exit 1
        fi

        rm -rf "${secret_name}" > /dev/null

        # Creates Secrets in AWS and Git
        if [ "${cloud_list_secrets_query_secret_res_sub_status}" == "904" ] && { [ "${github_get_user_keys_query_key_sub_status}" == "904" ] || [ "${github_get_user_keys_query_key_sub_status}" == "200" ]; }; then
          logger "INFO" "Creating ssh-key ${secret_name}" "${func_name}"
          if [ "${github_get_user_keys_query_key_sub_status}" == "200" ]; then
            logger "WARN" "A new ssh-key must be issue, because private ssh-key does not exist in 'local' machine and/or 'aws'" "${func_name}"
            # BASH 4+
            readarray -t key_ids < <( \
              jq \
                -n \
                -c \
                --argjson api_response "${github_key_query_key_res}" \
                '
                  $api_response
                  | .data[].id
                ' \
            )
            local github_delete_user_keys_res=""
            local github_delete_user_keys_res_status=""
            local github_delete_user_keys_res_sub_status=""
            for key_id in "${key_ids[@]}"; do
              local -a args_11=( \
                "delete-user-keys" \
                "delete-user-keys" \
                "${key_id}" \
              )
              github_delete_user_keys_res=$(utilQueryGithubResponses "${args_11[@]}")
              # Github api status
              github_delete_user_keys_res_status=$( \
                jq \
                  -n \
                  -r \
                  --argjson api_response "${github_delete_user_keys_res}" \
                  '
                    $api_response
                    | .status
                  '
              )
              # Github api sub-status
              github_delete_user_keys_res_sub_status=$( \
                jq \
                  -n \
                  -r \
                  --argjson api_response "${github_delete_user_keys_res}" \
                  '
                    $api_response
                    | .sub_status
                  '
              )
              # DELETE does not return error message, only code.
              if [ "${github_delete_user_keys_res_status}" == "204" ] && [ "${github_delete_user_keys_res_sub_status}" == "204" ]; then
                logger "INFO" "Deleted ssh key '${key_id}' in github." "${func_name}"
              else
                logger "ERROR" "Status ${github_delete_user_keys_res_status} | Sub-status: ${github_delete_user_keys_res_sub_status} | Unabled to delete ssh key in github."  "${func_name}"
                exit 1
              fi
              sleep 1
            done
          fi

          # Create Local first
          yes y \
            | ssh-keygen \
              -q \
              -t "${SSH_KEYGEN_DSA}" \
              -f "${secret_name_path}/${secret_file_name}"  \
              -C "${SSH_KEYGEN_COMMENT}" \
              -N ""
          local -r fingerprint=$(ssh-keygen -lf "${secret_name_path}/${secret_file_name}.pub" | awk '{print $2}')
          # local -r randomart_image=$(ssh-keygen -lvf "${secret_name_path}/${secret_file_name}.pub")

          # NOTE: preserves \n
          awk '{printf "%s\\n", $0}' "${secret_name_path}/${secret_file_name}" > "${secret_name_path}/${secret_file_name}.txt"

          # shellcheck disable=SC2016
          _secret_file_name="${secret_file_name}" \
          _secret_name_path="${secret_name_path}" \
          _fingerprint="${fingerprint}" \
          yq \
            -o json \
            '
              env(_secret_name_path) as $_secret_name_path
              | env(_secret_file_name) as $_secret_file_name
              | env(_fingerprint) as $_fingerprint
              | $_secret_name_path + "/" + $_secret_file_name as $full_path
              | {
                  "public": (load($full_path + ".pub")),
                  "private": (load($full_path + ".txt")),
                  "fingerprint": $_fingerprint
                }
            ' - > "${secret_name_path}/${secret_file_name}.json"

          # Creates AWS secret - create a cloud secret using the local ssh key
          logger "INFO" "Creating secret '${secret_name}' in AWS secrets-manager..." "${func_name}"
          local -ar args_8=( \
            "secretsmanager-create-secret" \
            "${cloud_account}" \
            "${cloud_profile}" \
            "${cloud_region}" \
            "secretsmanager-create-secret" \
            "${secret_name}" \
            "${secret_name_path}/${secret_file_name}" \
          )
          local -r secretsmanager_create_secret_res=$( \
            utilQueryAwsResponses "${args_8[@]}" \
          )
          local -r secretsmanager_create_secret_res_status=$( \
            jq \
              -n \
              -r \
              --argjson api_response "$secretsmanager_create_secret_res" \
              '
                $api_response
                | .status
              '
          )
          local -r secretsmanager_create_secret_res_sub_status=$( \
            jq \
              -n \
              -r \
              --argjson api_response "${secretsmanager_create_secret_res}" \
              '
                $api_response
                | .sub_status
              '
          )
          local -r secretsmanager_create_secret_res_error_message=$( \
            jq \
              -n \
              -r \
              --argjson api_response "${secretsmanager_create_secret_res}" \
              '
                $api_response
                | .data.message
              '
          )
          if [ "${secretsmanager_create_secret_res_status}" == "0" ] || [ "${secretsmanager_create_secret_res_sub_status}" == "0" ]; then
            # Creates ssh key in Github
            logger "INFO" "Creating '${secret_name}' in Github ssh key..." "${func_name}"
            local -r public_key=$( \
              jq \
                -r \
                '
                  .public
                ' "${secret_name_path}/${secret_file_name}.json"
            )
            # Github Create key
            local -ar args_9=( \
              "create-user-keys" \
              "create-user-keys" \
              "${secret_name}" \
              "${public_key}" \
            )
            local -r github_create_user_key_res=$(utilQueryGithubResponses "${args_9[@]}")
            local -r  github_create_user_key_res_status=$( \
              jq \
                -n \
                -r \
                --argjson api_response "$github_create_user_key_res" \
                '
                  $api_response
                  | .status
                '
            )
            local -r github_create_user_key_res_sub_status=$( \
              jq \
                -n \
                -r \
                --argjson api_response "${github_create_user_key_res}" \
                '
                  $api_response
                  | .sub_status
                '
            )
            local -r github_create_user_key_res_error_message=$( \
              jq \
                -n \
                -r \
                --argjson api_response "${github_create_user_key_res}" \
                '
                  $api_response
                  | .data.message
                '
            )
            if [ "${github_create_user_key_res_status}" == "201" ] || [ "${github_create_user_key_res_sub_status}" == "201" ]; then
              logger "INFO" "Secret ${secret_name} created in github." "${func_name}"
              exit 0
            else
              logger "ERROR" "${github_create_user_key_res_error_message}" "${func_name}"
              exit 1
            fi
          else
            logger "ERROR" "${secretsmanager_create_secret_res_error_message}" "${func_name}"
            exit 1
          fi
        # Since github only stores public key. we must always check AWS as source of truth.
        elif [ "${cloud_list_secrets_query_secret_res_sub_status}" == "0" ] && [ "${github_get_user_keys_query_key_sub_status}" == "200" ]; then
          logger "INFO" "Download the aws secret to local and match aws and github ssh keys" "${func_name}"
          jq \
            -n \
            --argjson api_response "${cloud_list_secrets_query_secret_res}" \
            '
              $api_response
              | .data
            ' > "${secret_name_path}/${secret_file_name}.json"

          jq \
            -n \
            -r \
            --argjson api_response "${cloud_list_secrets_query_secret_res}" \
            '
              $api_response
              | .data.private
            ' \
            > "${secret_name_path}/_${secret_file_name}"

          sed 's/\\n/\n/g' < "${secret_name_path}/_${secret_file_name}" > "${secret_name_path}/${secret_file_name}"
          rm "${secret_name_path}/_${secret_file_name}"

          jq \
            -n \
            -r \
            --argjson api_response "${cloud_list_secrets_query_secret_res}" \
            '
              $api_response
              | .data.public
            ' > "${secret_name_path}/${secret_file_name}.pub"

          local -r aws_public_key=$( \
            jq \
              -r \
              '
                .public
              ' "${secret_name_path}/${secret_file_name}.json"
          )
          # BASH 4+
          readarray -t github_ssh_key_ids_to_delete < <( \
            jq \
              -n \
              -c \
              -r \
              --arg aws_public_key "${aws_public_key}" \
              --argjson api_response "${github_key_query_key_res}" \
              '
                $api_response
                | ($aws_public_key | split(" ") | (.[0] + " " + .[1])) as $_sanitized_aws_public_key
                | [
                    .data[]
                    | . as $obj
                    | .key
                    | if (. != $_sanitized_aws_public_key) then
                        $obj.id
                      else
                        empty
                      end
                  ]
                | .[]
              ' \
          )

          local -r github_ssh_key_ids_matched_with_aws_ssh_key=$( \
            jq \
              -n \
              -c \
              -r \
              --arg aws_public_key "${aws_public_key}" \
              --argjson api_response "${github_key_query_key_res}" \
              '
                $api_response
                | ($aws_public_key | split(" ") | (.[0] + " " + .[1])) as $_sanitized_aws_public_key
                | [
                    .data[]
                    | . as $obj
                    | .key
                    | if (. == $_sanitized_aws_public_key) then
                        .
                      else
                        empty
                      end
                  ]
                | (. | length) > 0
              ' \
          )

          if [ "${github_ssh_key_ids_matched_with_aws_ssh_key}" == "true" ]; then
            logger "INFO" "AWS and Github ssh key match." "${func_name}"
          else
            # DELETE KEYS THAT DON'T MATCH
            logger "ERROR" "AWS and Github ssh key does not match. All github ssh-keys with the same name will be deleted." "${func_name}"
            local should_run_command_again="true"
            for github_ssh_key_id_to_delete in "${github_ssh_key_ids_to_delete[@]}"; do
              logger "ERROR" "Deleting ssh key ${github_ssh_key_id_to_delete}" "${func_name}"
              local -a args_12=( \
                "delete-user-keys" \
                "delete-user-keys" \
                "${github_ssh_key_id_to_delete}" \
              )
              github_delete_user_keys_res_2=$(utilQueryGithubResponses "${args_12[@]}")
              # Github api status
              github_delete_user_keys_res_status_2=$( \
                jq \
                  -n \
                  -r \
                  --argjson api_response "${github_delete_user_keys_res_2}" \
                  '
                    $api_response
                    | .status
                  '
              )
              # Github api sub-status
              github_delete_user_keys_res_sub_status_2=$( \
                jq \
                  -n \
                  -r \
                  --argjson api_response "${github_delete_user_keys_res_2}" \
                  '
                    $api_response
                    | .sub_status
                  '
              )
              # DELETE does not return error message, only code.
              if [ "${github_delete_user_keys_res_status_2}" == "204" ] && [ "${github_delete_user_keys_res_sub_status_2}" == "204" ]; then
                logger "INFO" "Deleted ssh key '${github_ssh_key_id_to_delete}' in github." "${func_name}"
              else
                logger "ERROR" "Status ${github_delete_user_keys_res_status_2} | Sub-status: ${github_delete_user_keys_res_sub_status_2} | Unabled to delete ssh key in github."  "${func_name}"
                should_run_command_again="false"
              fi
            done
            if [ "${should_run_command_again}" == "true" ]; then
              logger "INFO" "Command will safely re-execute itself." "${func_name}"
              # TODO: execute itself or must be re-executed manually...
            else
              logger "ERROR" "Before re-executing the same command, make sure you solve the issue. Github did not delete some keys successfully." "${func_name}"
              exit 1
            fi
          fi
        elif [ "${cloud_list_secrets_query_secret_res_sub_status}" == "0" ] && [ "${github_get_user_keys_query_key_sub_status}" == "904" ]; then
          logger "INFO" "Downloading ssh key from AWS secret to local and will upload to Github..." "${func_name}"
          # Download to local
          jq \
            -n \
            --argjson api_response "${cloud_list_secrets_query_secret_res}" \
            '
              $api_response
              | .data
            ' > "${secret_name_path}/${secret_file_name}.json"

          jq \
            -n \
            -r \
            --argjson api_response "${cloud_list_secrets_query_secret_res}" \
            '
              $api_response
              | .data.private
            ' \
            > "${secret_name_path}/_${secret_file_name}"

          sed 's/\\n/\n/g' < "${secret_name_path}/_${secret_file_name}" > "${secret_name_path}/${secret_file_name}"
          rm "${secret_name_path}/_${secret_file_name}"
          jq \
            -n \
            -r \
            --argjson api_response "${cloud_list_secrets_query_secret_res}" \
            '
              $api_response
              | .data.public
            ' > "${secret_name_path}/${secret_file_name}.pub"

          # Github Create key
          local -r public_key_2=$( \
            jq \
              -r \
              '
                .public
              ' "${secret_name_path}/${secret_file_name}.json"
          )
          local -ar args_10=( \
            "create-user-keys" \
            "create-user-keys" \
            "${secret_name}" \
            "${public_key_2}" \
          )
          local -r github_create_user_key_res_2=$(utilQueryGithubResponses "${args_10[@]}")
          local -r  github_create_user_key_res_status_2=$( \
            jq \
              -n \
              -r \
              --argjson api_response "$github_create_user_key_res_2" \
              '
                $api_response
                | .status
              '
          )
          local -r github_create_user_key_res_sub_status_2=$( \
            jq \
              -n \
              -r \
              --argjson api_response "${github_create_user_key_res_2}" \
              '
                $api_response
                | .sub_status
              '
          )
          local -r github_create_user_key_res_error_message_2=$( \
            jq \
              -n \
              -r \
              --argjson api_response "${github_create_user_key_res_2}" \
              '
                $api_response
                | .data.message
              '
          )
          if [ "${github_create_user_key_res_status_2}" == "201" ] || [ "${github_create_user_key_res_sub_status_2}" == "201" ]; then
            logger "INFO" "Secret ${secret_name} created." "${func_name}"
          else
            logger "ERROR" "${github_create_user_key_res_error_message_2}" "${func_name}"
            exit 1
          fi
        else
          logger "ERROR" "Unhandled error." "${func_name}"
          exit 1
        fi
      ;;
    "azure") # microsoft cloud
      ;;
    "gcp") # google cloud
      ;;
    "oci") # oracle cloud
      ;;
    "ibm") # ibm cloud
      ;;
    *)
      logger "Does not support cloud ${cloud_name}"
      ;;
  esac
}
