#!/bin/bash

#
# TODO:
#   - create jq function to stay DRY
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - queries `../docker-images.yaml` file.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function utilQueryDockerImagesFile () {
  local -r func_name="${FUNCNAME[0]}"
  local -r _path="${PLATFORM_PATH}/boilerplate/docker-images.yaml"
  local -r args=("$@")
  local -r query_name="${args[0]}"

  case "${query_name}" in
    "read-components-names")
      yq \
        -r \
        '
          .components | keys
          | .[]
        ' "${_path}"
      ;;
    #
    # NOTES:
    #   - If `null`, it returns all components names
    #   - If "null,apis,uis", it returns "apis,uis"
    #   - It returns only components names that exist in docker-images.yaml
    #     ex: if component "test" doesn't exist, it will remove from output.
    #
    "read-components-names-if-exist")
      local components="${args[1]}"
      yq \
        -r \
        -o json \
        '
          .components | keys
        ' "${_path}" \
        | jq \
          -r \
          --arg components "${components}" \
          '
            include "jq-functions";
            getDockerImagePaths($components; "bash-array")
          '
      ;;
    #
    # NOTES:
    #   - it assumes component_name exist in docker-images.yaml
    #
    "read-component-apps-names-if-exist")
      local component_name="${args[1]}"
      local apps="${args[2]}"

      # shellcheck disable=SC2016
      _component_name="${component_name}" \
      yq \
        -r \
        -o json \
        '
          env(_component_name) as $_component_name
          | .components[$_component_name] | keys
        ' "${_path}" \
        | jq \
          -r \
          --arg apps "$apps" \
          '
            include "jq-functions";
            getDockerImagePaths($apps; "bash-array")
          '
      ;;
    #
    # NOTES:
    #   - it assumes component_name and app_name exist in docker-images.yaml
    #
    "read-component-app-projects-names-if-exist")
      local component_name="${args[1]}"
      local app_name="${args[2]}"
      local projects="${args[3]}"

      # shellcheck disable=SC2016
      _component_name="${component_name}" \
      _app_name="${app_name}" \
      yq \
        -r \
        -o json \
        '
          env(_component_name) as $_component_name
          | env(_app_name) as $_app_name
          | .components[$_component_name][$_app_name] | keys
        ' "${_path}" \
        | jq \
          -r \
          --arg projects "$projects" \
          '
            include "jq-functions";
            getDockerImagePaths($projects; "bash-array")
          '
      ;;
    "read-components-apps-projects-paths")
      local components="${args[1]}"
      local apps="${args[2]}"
      local projects="${args[3]}"
      yq \
        -r \
        -o json \
        '
          .
        ' "${_path}" \
        | jq \
          --arg components "${components}" \
          --arg apps "${apps}" \
          --arg projects "${projects}" \
          '
            include "jq-functions";
            . as $main_obj
            | $main_obj.components | keys
            | getDockerImagePaths($components; "jq-array")
            | .[] as $component_name
            | $main_obj.components[$component_name] | keys
            | getDockerImagePaths($apps; "jq-array")
            | .[] as $app_name
            | $main_obj.components[$component_name][$app_name] | keys
            | getDockerImagePaths($projects; "jq-array")
            | .[] as $project_name
            | $component_name + "/" + $app_name + "/" + $project_name
          '
      ;;
    "read-components-apps-projects-enabled")
      # TODO
      #   - support defaults when $components, $apps, $p_search are null
      #     if null, it should search for all available options.
      #   - maybe just use yq?
      yq \
        -r \
        -o json \
        '
          .
        ' "${_path}" \
        | jq \
          --arg components "${components}" \
          --arg apps "${apps}" \
          --arg projects "${projects}" \
          '
            include "jq-functions";
            splitStr($components) as $c_search
            | splitStr($apps) as $a_search
            | splitStr($projects) as $p_search
            | .
            | .components.private |= (
                .
                | to_entries
                | map(
                    .key as $c_key
                    | select(($c_search | select(.[] == $c_key)))
                    | .value |= (
                        to_entries
                        | map(
                            .key as $a_key
                            | select(($a_search | select(.[] == $a_key)))
                            | .value |= (
                                to_entries
                                | map(
                                    .key as $p_key
                                    | .value as $p_value
                                    | select(($p_search | select(.[] == $p_key)))
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
            | .
          ' \
          | yq -P
      ;;
    *)
      ;;
  esac
}
