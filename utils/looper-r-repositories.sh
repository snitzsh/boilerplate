#!/bin/bash

#
# TODO:
#   - after building images, tag to remote registry and push
#   - support sync of tags on different cloud registries and add them in
#     docker-images.yaml
#
# NOTE:
#   - it loops through ./hc-c-dependencies.yaml
#   - it will build regardless if its not running in cluster
#
# DESCRIPTION:
#   - loops all repositories.
#   - for snitzsh, it will use dockerfile build
#     and loop `repository_language`
#   - other command will build the helm-chart and uploaded to
#     s3 or chartmuseum. This one may required that an environment is
#     running and s3 bucket exits.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function utilLooperRRepositories () {
  local -r func_name="${FUNCNAME[0]}"
  local -a args=("$@")
  local -r query_name=$(utilReadArgValue "${func_name}" "null" "query-name" "${args[0]}")
  # apis, uis, scripts
  local -r components=$(utilReadArgValue "${func_name}" "${query_name}" "components" "${args[0]}")
  # snitzsh, lottery, xxx2
  local -r apps=$(utilReadArgValue "${func_name}" "${query_name}" "apps" "${args[0]}")
  # main-rust
  local -r projects=$(utilReadArgValue "${func_name}" "${query_name}" "projects" "${args[0]}")
  # up | down
  local -r action=$(utilReadArgValue "${func_name}" "${query_name}" "action" "${args[0]}")
  local -r docker_composer_path="${PLATFORM_PATH}/scripts/global/docker_compose-bash"

  case "${query_name}" in
    "r-create-images")
      local args_2=( \
        "read-components-apps-projects-enabled" \
        "${components}" \
        "${apps}" \
        "${projects}" \
      )
      local docker_images_yaml=""
      # TODO:
      #   - Here we need to get the repositories version from package.json
      #     or .rust version
      docker_images_yaml=$(utilQueryDockerImagesFile "${args_2[@]}")

      (
        # shellcheck disable=SC2016
        cd "${docker_composer_path}" && \
        # 1 - docker-componse.yml
        # 0 - docker-images.yaml
        echo "${docker_images_yaml}" \
        | yq \
            eval-all \
            '
              (
                select(fileIndex == 1)
                | (.components | keys) as $t_keys
                | .apps |= []
                | .registries |= []
                | $t_keys[] as $_type
                | .components[$_type] |= (
                    to_entries
                    | map(
                        .value |= (
                          to_entries
                          | map(
                              .value |= (
                                to_entries
                                | map(
                                    .value.enabled |= false
                                  )
                                | from_entries
                                | with_entries(
                                    select(.value | length > 0)
                                  )
                              )
                            )
                          | from_entries
                          | with_entries(
                              select(.value | length > 0)
                            )
                        )
                      )
                    | from_entries
                    | with_entries(
                        select(.value | length > 0)
                      )
                  )
              ) *+ select(fileIndex == 0)
              | . as $item ireduce ({}; . * $item )
            ' - values.yaml \
          | helm template . -f - \
          | if [ "${action}" == "up" ]; then
              docker compose -f - \
                --progress "auto" \
                up \
                  --build \
                  --detach \
                  --force-recreate
            else
              docker compose -f - \
                down
            fi
      )
      ;;
    # Else
    *)
      local args_2=( \
        "read-components-names-if-exist" \
        "${components}" \
      )
      while IFS= read -r component_name; do
        local args_3=( \
          "read-component-apps-names-if-exist" \
          "${component_name}" \
          "${apps}" \
        )
        while IFS= read -r app_name; do
          local args_4=( \
            "read-component-app-projects-names-if-exist" \
            "${component_name}" \
            "${app_name}" \
            "${projects}" \
          )
          while IFS= read -r project_name; do
            # TODO: return error if it cannnot cd to project
            (
              cd "${PLATFORM_PATH}/${component_name}/${app_name}/${project_name}" &&
              case "${query_name}" in
                "r-create-images")
                  ls
                  ;;
                *)
                  ;;
              esac
            )
          done < <(
            utilQueryDockerImagesFile "${args_4[@]}"
          )
        done < <(
          utilQueryDockerImagesFile "${args_3[@]}"
        )
      done < <(
        utilQueryDockerImagesFile "${args_2[@]}"
      )

      ;;
  esac

}
