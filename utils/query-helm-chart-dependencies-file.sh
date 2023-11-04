#!/bin/bash
# TODO:
# - Merge the function into one, just like in ./query-cluster-yaml.sh

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Get the all dependencies of the platform from ../helm-chart-dependencies.yaml
#
# ARGS:
#   - null
#
# RETURN:
#   - Array  : dependencies
#     * example >
#     *   (argo.argo-cd argo.argo-workflows)
#
#
utilGetHelmChartDependecies () {
  local -a arr=()
  local -r helm_chart_dependencies_path="${SNITZSH_PATH}/boilerplate/helm-chart-dependencies.yaml"
  while IFS='' read -r line; do arr+=("$line"); done < <(
    # yq doesn't have an easy way to return a bash array. So using jq is the
    # easiest way.
    yq -o=json '
      [
        .dependencies[]
        | {"dependency": .name, "chart": (.charts[].name)}
        | .dependency + "|" + .chart
      ]
    ' "${helm_chart_dependencies_path}" | jq -r '.[]'
  )
  echo "${arr[@]}"
}

#
# TODO:
#   - return an (empty object or false) if a dependency cannot be found.
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Gets the specific dependency chart from ../helm-chart-dependencies.yaml
#
# ARGS:
#   - dependency_name
#   - chart_name
#
# RETURN:
#   - String  : `dependency chart object` OR `false`
#     * example >
#     *   '{...}'
#
#
utilGetHelmChartDependency () {
  local -r helm_chart_dependencies_path="${SNITZSH_PATH}/boilerplate/helm-chart-dependencies.yaml"
  local -r dependency_name="${1}"
  local -r chart_name="${2}"
  local dependency=""
  dependency=$( \
    # shellcheck disable=SC2016
    _dependency_name="${dependency_name}" \
    _chart_name="${chart_name}" \
    yq '
      env(_dependency_name) as $_dependency_name
      | env(_chart_name) as $_chart_name
      | .dependencies[]
      | select(.name == $_dependency_name)
      | .repository as $repository
      | .charts[]
      | select(.name == $_chart_name)
      | .dependency_name |= $_dependency_name
      | .repository |= $repository
      | .
    ' "${helm_chart_dependencies_path}" \
  )
  echo "${dependency}"
}

#
# TODO:
#   - add desc, args, return
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
utilQueryHelmChartDependenciesFile () {
  local -r helm_chart_dependencies_path="${SNITZSH_PATH}/boilerplate/helm-chart-dependencies.yaml"
  local -r query_name="${1}"

  case "${query_name}" in
    "update-{dependency}-version")
      local -r dependency_name="${2}"
      local -r chart_name="${3}"
      local -r latest_version="${4}"
      # shellcheck disable=SC2016
      _dependency_name="${dependency_name}" \
      _chart_name="${chart_name}" \
      _latest_version="${latest_version}" \
      yq '
        env(_dependency_name) as $_dependency_name
        | env(_chart_name) as $_chart_name
        | env(_latest_version) as $_latest_version
        | (..)
      ' "${helm_chart_dependencies_path}"
      ;;
    *)
      echo ""
      ;;
  esac
}

#
# TODO:
#   - add desc, args, return
#   - maybe add a argument that can return comments if true.
#
# NOTE:
#   - when using output with jq, it will not work because it contains comments
#     that why comments are removed in the last line.
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
utilQueryHelmChartDependenciesFileObjGET () {
  local -r obj="${1}"
  local -r prop="${2}"
  local output_type="${3}" # use incase we need to use jq with the output
  if [ "${output_type}" == "" ]; then
    output_type="yaml"
  fi

  # shellcheck disable=SC2016
  _obj="${obj}" \
  _prop="${prop}" \
  yq \
    -nr \
    -o "${output_type}" \
    '
      env(_obj) as $_obj
      | env(_prop) as $_prop
      | $_obj
      | .
      | .[$_prop]
      | ... comments=""
    '
}

#
# TODO:
#   - add desc, args, return
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
utilQueryHelmChartDependenciesFileGET () {
  local -r helm_chart_dependencies_path="${SNITZSH_PATH}/boilerplate/helm-chart-dependencies.yaml"
  local -ar args=("$@")
  local -r query_name="${args[0]}"
  case "${query_name}" in
    "get-{dependency}-{chart}-prop")
      local -r dependency_name="${args[1]}"
      local -r chart_name="${args[2]}"
      local -r prop="${args[3]}"
        _dependency_name="${dependency_name}" \
        _chart_name="${chart_name}" \
        _prop="${prop}" \
        yq \
          -r \
          '
            .dependencies[]
            | select(.name == env(_dependency_name))
            | .charts[]
            | select(.name == env(_chart_name))
            | .[env(_prop)]
          ' "${helm_chart_dependencies_path}" \
      ;;
    *)
      echo ""
      ;;
  esac
}

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
utilQueryHelmChartDependenciesFilePUT () {
  local -r helm_chart_dependencies_path="${SNITZSH_PATH}/boilerplate/helm-chart-dependencies.yaml"
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
