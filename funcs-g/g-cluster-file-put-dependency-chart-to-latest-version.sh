#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - the .release array order comes from helm command
#     `helm search repo dependency_name/chart_name --versions`
#
# DESCRIPTION:
#   - null
#
# ARGS:
#   - null
#                                             : may need an argument to get data for specific region.
# RETURN:
#   - null
#
funcClustersYamlPutDependencyChartToLatestVersion () {
  local -r func_name="${FUNCNAME[0]}"
  local -a args=("$@")
  local -r region_name="${args[0]}"
  local -r cluster_name="${args[1]}"
  local -r dependency_name="${args[2]}"
  local -r chart_name="${args[3]}"
  local -r dependency="${args[4]}" # obj as string.

  # Repository
  local helm_repository_latest_version=""
  helm_repository_latest_version=$( \
    utilGlobalHelmGetRepositoryChartVersion "${dependency_name}" "${chart_name}" \
  )

  if [ "${helm_repository_latest_version}" == "false" ]; then
    logger "ERROR" "Dependency '${dependency_name}/${chart_name}' does not exist in local machine or hasn't been install or is not yet available in remote registry. Run 'bash main.sh \"g-helm-install-repositories\"." "${func_name}"
  else
    # Repository
    local -r helm_repository_latest_version_obj=$( \
      utilVersionerGetVersionAsObj "${helm_repository_latest_version}" \
    )
    local -r helm_repository_latest_version_is_valid=$( \
      utilVersionerIsVersionObjQuery "is_valid" "${helm_repository_latest_version_obj}" \
    )
    local -r helm_repository_latest_version_x_x_x_num=$( \
      utilVersionerIsVersionObjQuery "x_x_x_num" "${helm_repository_latest_version_obj}"
    )

    # Current Version
    local -r args_1=( \
      "get-{region_name}-{cluster_name}-{dependency_name}-{chart_name}-prop" \
      "${dependency}" \
      "version" \
      "yaml"  \
    )
    local -r current_version=$( \
      utilQueryClustersYaml "${args_1[@]}" \
    )
    local -r current_version_obj=$( \
      utilVersionerGetVersionAsObj "${current_version}" \
    )
    local -r current_version_is_valid=$( \
      utilVersionerIsVersionObjQuery "is_valid" "${current_version_obj}" \
    )
    local -r current_version_x_x_x_num=$( \
      utilVersionerIsVersionObjQuery "x_x_x_num" "${current_version_obj}"
    )

    # Compare
    local -r is_helm_repository_latest_version_equals_to_current_version=$( \
      utilVersionerCompareVersions \
        "equals" \
        "${helm_repository_latest_version_x_x_x_num}" \
        "${current_version_x_x_x_num}" \
    )

    #
    # NOTE:
    # - yq's sort_by is buggy some number are not order property.
    if [ "${helm_repository_latest_version_is_valid}" == "true" ] && [ "${current_version_is_valid}" == "true" ]; then
      local release_version_obj="{}"
      local is_release_version_valid="false"
      local release_version_x_x_x_num=""
      local is_release_version_greater_greater_current_version="false"
      local -a helm_releases=()
      local -a all_helm_releases=()

      while IFS= read -r value; do
        release_version_obj=$(utilVersionerGetVersionAsObj "${value}")
        is_release_version_valid=$( \
          utilVersionerIsVersionObjQuery "is_valid" "${release_version_obj}" \
        )

        if [ "${is_release_version_valid}" == "true" ]; then
          release_version_x_x_x_num=$( \
            utilVersionerIsVersionObjQuery "x_x_x_num" "${release_version_obj}" \
          )

          is_release_version_greater_greater_current_version=$( \
            utilVersionerCompareVersions \
              "greater_than" \
              "${release_version_x_x_x_num}" \
              "${current_version_x_x_x_num}" \
          )
          if [ "${is_release_version_greater_greater_current_version}" == "true" ]; then
            helm_releases+=("${value}")
          fi
          all_helm_releases+=("${value}")
        else
          logger "ERROR" "Dependency '${dependency_name}/${chart_name}' latest version '${helm_repository_latest_version}' is not valid." "${func_name}"
        fi
      done < <(\
        # shellcheck disable=SC2016
        helm \
          search \
            repo "${dependency_name}/${chart_name}" \
              --versions \
              -o yaml \
        | _dependency_name="${dependency_name}" \
          _chart_name="${chart_name}" \
          yq \
            -r \
            '
              env(_dependency_name) as $_dependency_name
              | env(_chart_name) as $_chart_name
              | .[]
              | select(.name == $_dependency_name + "/" + $_chart_name)
              | .version
            '
      )

      local version_exist_in_releases="false"
      version_exist_in_releases=$( \
        # shellcheck disable=SC2016
        _all_helm_releases="${all_helm_releases[*]}" \
        _current_version="${current_version}" \
        yq \
          -n \
          '
            env(_all_helm_releases) as $_all_helm_releases
            | env(_current_version) as $_current_version
            | $_all_helm_releases
            | . | split(" ")
            | .[] | select(. == $_current_version)
            | . == $_current_version
          ' \
      )
      if [ "${version_exist_in_releases}" == "true" ]; then
        if [ "${#helm_releases}" -lt "1" ]; then
          helm_releases_stringified="null"
        else
          helm_releases_stringified="${helm_releases[*]}"
        fi

        local -ar args_3=( \
          "put-{region_name}-{cluster_name}-{dependency_name}-{chart_name}-to-latest-version" \
          "${region_name}" \
          "${cluster_name}" \
          "${dependency_name}" \
          "${chart_name}" \
          "${helm_repository_latest_version}" \
          "${helm_releases_stringified}" \
          "${is_helm_repository_latest_version_equals_to_current_version}" \
        )

        new_dependency_chart_obj=$( \
          utilQueryClustersYaml "${args_3[@]}" \
        )

        local -ar args_4=( \
          "put-{region_name}-{cluster_name}-{dependency_name}-{chart_name}-object" \
          "${region_name}" \
          "${cluster_name}" \
          "${dependency_name}" \
          "${chart_name}" \
          "${new_dependency_chart_obj}" \
        )

        utilQueryClustersYaml "${args_4[@]}"
        logger "INFO" "clusters.yaml for chart '.${region_name}.${cluster_name}.${dependency_name}.${chart_name}' object has been updated." "${func_name}"
        sleep 1 # mainly for I/O fs. If not it will not update the file property.
      fi
    else
      logger "ERROR" "Dependency '${dependency_name}/${chart_name}' latest version '${helm_repository_latest_version}' is not valid." "${func_name}"
    fi
  fi
}
