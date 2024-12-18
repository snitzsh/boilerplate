#!/bin/bash

#
# TODO:
#   - add desc, args, return
#   - Commented the line that adds a comment to .release, when array is empty,
#     it puts the comment before `[]`, causing yq to fail with error. Find out
#     how to fix it where we can add a comment after the bracket.
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
function utilQueryHelmChartDependenciesFilePUT () {
  local -r helm_chart_dependencies_path="${PLATFORM_PATH}/boilerplate/hc-c-dependencies.yaml"
  local -ar args=("$@")
  local -r query_name="${args[0]}"

  case "${query_name}" in
    "{dependency}-{chart_name}-put-to-latest-version")
      local -r dependency_name="${args[1]}"
      local -r chart_name="${args[2]}"
      local -r latest_version="${args[3]}"
      local -r releases="${args[4]}"
      local -r is_up_to_date="${args[5]}"
      # | (.releases | key) line_comment="DESCRIPTION: Releases history. Must be >= .version. IMPORTANT: Do NOT edit this property (key/values) manually. Use boilerplate repo to get new releases."
      # shellcheck disable=SC2016
      _dependency_name="${dependency_name}" \
      _chart_name="${chart_name}" \
      _latest_version="${latest_version}" \
      _releases="${releases}" \
      _is_up_to_date="${is_up_to_date}" \
      yq \
        -r \
        -P \
        '
          "DESCRIPTION: Latest version of the helm-chart. IMPORTANT: Do NOT edit this property (key/values) manually. Use boilerplate repo to get the latest version." as $latest_comment
          | "DESCRIPTION: Check if chart is up-to-date. IMPORTANT: Do NOT edit this property (key/values) manually. Use boilerplate repo to update the value." as $is_up_to_date_comment
          | "DESCRIPTION: Releases history. Must be >= .version. IMPORTANT: Do NOT edit this property (key/values) manually. Use boilerplate repo to get new releases." as $releases_comment
          | env(_dependency_name) as $_dependency_name
          | env(_chart_name) as $_chart_name
          | env(_latest_version) as $_latest_version
          | env(_releases) as $_releases
          | env(_is_up_to_date) as $_is_up_to_date
          | .dependencies[]
          | select(.name == $_dependency_name)
          | .charts[]
          | select(.name == $_chart_name)
          | .latest_version |= $_latest_version
          | .latest_version line_comment=$latest_comment
          | .releases |= $_releases
          | .is_up_to_date |= $_is_up_to_date
          | .is_up_to_date line_comment=$is_up_to_date_comment
          | .
        ' "${helm_chart_dependencies_path}"
      ;;
    # TODO:
    #   - Consider this to be a function, since this updates the file it doesn't return output.
    "{dependency}-{chart_name}-new-object")
      local -r dependency_name="${args[1]}"
      local -r chart_name="${args[2]}"
      local -r new_obj="${args[3]}"

      # shellcheck disable=SC2016
      _dependency_name="${dependency_name}" \
      _chart_name="${chart_name}" \
      _new_obj="${new_obj}" \
      yq \
        -ri \
        '
          (
            .dependencies[]
            | select(.name == env(_dependency_name))
            | .charts[]
            | select(.name == env(_chart_name))
          ) = env(_new_obj)
          | .
        ' "${helm_chart_dependencies_path}"
      ;;
    *)
      return 1
      ;;
  esac
}
