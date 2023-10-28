#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - create another function that installs the helm-repo first. this function
#     assumes that it has already been installed...
#
# NOTE:
#   - It does NOT modify the .version (deployed version).
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
funcHelmChartDependenciesFileUpdateToLatestVersion () {
  local -r func_name="${FUNCNAME[0]}"
  local -a args=("$@")
  local -r dependency_name="${args[0]}"
  local -r chart_name="${args[1]}"
  local -r dependency="${args[2]}" # obj as string.
  local repository_version=""

  repository_version=$( \
    utilGlobalGetRepositoryChartVersion "$dependency_name" "${chart_name}" \
  )

  if [ "${repository_version}" == "false" ]; then
    logger "ERROR" "Dependency '${dependency_name}/${chart_name}' does not exist in local machine or hasn't been install or is not yet available in remote registry. Run 'bash main.sh \"g-helm-install-repositories\"." "${func_name}"
  else
    # Here update the file...
    local -r repository_version_obj=$( \
      utilGetVersionAsObj "${repository_version}" \
    )
    local -r repository_version_is_valid=$( \
      utilIsVersionObjQuery "is_valid" "${repository_version_obj}" \
    )

    # Current Version
    local -r current_version=$( \
      utilQueryHelmChartDependenciesFileObjGET "${dependency}" "version" "yaml" \
    )
    local -r current_version_obj=$( \
      utilGetVersionAsObj "${current_version}" \
    )

    local -r current_version_is_valid=$( \
      utilIsVersionObjQuery "is_valid" "${current_version_obj}" \
    )

    if [ "${repository_version_is_valid}" == "true" ] && [ "${current_version_is_valid}" == "true" ]; then
      local releases=""
      releases=$( \
        utilQueryHelmChartDependenciesFileObjGET "${dependency}" "releases" "json" \
      )
      local version=""
      version=$( \
        utilQueryHelmChartDependenciesFileObjGET "${dependency}" "version" "yaml" \
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

      clean_new_releases=$( \
        utilCleanUpReleasesProp "${new_releases}" "${version}" \
      )

      # Compare Repository vs Current Version
      repository_version_x_x_x_num=$( \
        utilIsVersionObjQuery "x_x_x_num" "${repository_version_obj}"
      )
      current_version_x_x_x_num=$( \
        utilIsVersionObjQuery "x_x_x_num" "${current_version_obj}"
      )

      repository_version_equals_to_current_version=$( \
        utilCompareVersions \
          "equals" \
          "${repository_version_x_x_x_num}" \
          "${current_version_x_x_x_num}" \
      )

      local -ar args=( \
        "{dependency}-{chart_name}-update-to-latest-version" \
        "${dependency_name}" \
        "${chart_name}" \
        "${repository_version}" \
        "${clean_new_releases}" \
        "${repository_version_equals_to_current_version}" \
      )

      new_dependency_chart_obj=$( \
        utilQueryHelmChartDependenciesFilePUT "${args[@]}" \
      )

      local -ar args_2=( \
        "{dependency}-{chart_name}-new-object" \
        "${dependency_name}" \
        "${chart_name}" \
        "${new_dependency_chart_obj}" \
      )
      utilQueryHelmChartDependenciesFilePUT "${args_2[@]}"
      logger "INFO" "Dependencies file for dependency '${dependency_name}/${chart_name}' has been updated." "${func_name}"
      sleep 1 # mainly for I/O fs. If not it will not update the file property.
    else
      logger "ERROR" "Dependency '${dependency_name}/${chart_name}' latest version '${repository_version}' is not valid." "${func_name}"
    fi
  fi
}
