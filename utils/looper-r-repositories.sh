#!/bin/bash

#
# TODO:
#   - after building images, tag to remote registry and push
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
  local -r query_name="${args[0]}"
  local -r components="${args[1]}" # apis, uis, scripts
  local -r apps="${args[2]}" # snitzsh, lottery, xxx2
  local -r projects="${args[3]}" # main-rust
  local -r docker_composer_path="${PLATFORM_PATH}/scripts/global/docker_compose-bash"

  case "${query_name}" in
    "r-create-images")
      local args_2=( \
        "read-components-apps-projects-enabled" \
        "${components}" \
        "${apps}" \
        "${projects}" \
      )
      utilQueryDockerImagesFile "${args_2[@]}"
      (
        cd "${docker_composer_path}" && \
        ls
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
