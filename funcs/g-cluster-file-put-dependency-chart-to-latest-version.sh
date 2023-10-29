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
  local repository_version=""
  repository_version=$( \
    utilGlobalGetRepositoryChartVersion "${dependency_name}" "${chart_name}" \
  )

  if [ "${repository_version}" == "false" ]; then
    logger "ERROR" "Dependency '${dependency_name}/${chart_name}' does not exist in local machine or hasn't been install or is not yet available in remote registry. Run 'bash main.sh \"g-helm-install-repositories\"." "${func_name}"
  else
    local -r repository_version_obj=$( \
      utilGetVersionAsObj "${repository_version}" \
    )
    local -r repository_version_is_valid=$( \
      utilIsVersionObjQuery "is_valid" "${repository_version_obj}" \
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
      utilGetVersionAsObj "${current_version}" \
    )
    local -r current_version_is_valid=$( \
      utilIsVersionObjQuery "is_valid" "${current_version_obj}" \
    )


    if [ "${repository_version_is_valid}" == "true" ] && [ "${current_version_is_valid}" == "true" ]; then
      # Releases
      local -r args_2=( \
        "get-{region_name}-{cluster_name}-{dependency_name}-{chart_name}-prop" \
        "${dependency}" \
        "releases" \
        "json"  \
      )
      local releases=""
      releases=$( \
        utilQueryClustersYaml "${args_2[@]}" \
      )

      # NOTE: jq index return null if not found.
      local new_releases=""
      new_releases=$( \
        jq \
          -nr \
          --argjson releases "${releases}" \
          --arg repository_version "${repository_version}" \
          '
            $releases
            | . | index($repository_version) as $found
            | $releases
            | if (($found | type) == "null") then
              . += [$repository_version]
              end
            | .
          ' \
      )
      # Removes Clusters.
      clean_new_releases=$( \
        utilVersionerCleanUpReleasesProp "${new_releases}" "${current_version}" \
      )
      # Compare Repository vs Current Version
      repository_version_x_x_x_num=$( \
        utilIsVersionObjQuery "x_x_x_num" "${repository_version_obj}"
      )
      current_version_x_x_x_num=$( \
        utilIsVersionObjQuery "x_x_x_num" "${current_version_obj}"
      )
      repository_version_equals_to_current_version=$( \
        utilVersionerCompareVersions \
          "equals" \
          "${repository_version_x_x_x_num}" \
          "${current_version_x_x_x_num}" \
      )

      local -ar args_3=( \
        "put-{region_name}-{cluster_name}-{dependency_name}-{chart_name}-to-latest-version" \
        "${region_name}" \
        "${cluster_name}" \
        "${dependency_name}" \
        "${chart_name}" \
        "${repository_version}" \
        "${clean_new_releases}" \
        "${repository_version_equals_to_current_version}" \
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
    else
      logger "ERROR" "Dependency '${dependency_name}/${chart_name}' latest version '${repository_version}' is not valid." "${func_name}"
    fi
  fi
}
