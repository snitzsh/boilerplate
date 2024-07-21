#!/bin/bash

#
# TODO:
#   - on cluster.yaml, makes clusters prop an array, because there can be
#     multiple clusters in the same region
#
# NOTE:
#   - if ${1} is not specified it return "false"
#
# DESCRIPTION:
#   - Queries the file clusters.yaml file.
#
# ARGS:
#   - $1  : ARRAY  :  "${args[@]}"  :  ("<[query_name]> | required" "<[any]> | optional" "...")  :  query name (index 0) is required, everything else is optional.
#
# RETURN:
#   - Array | Boolean : ("name1" "name2") | "false"
#
function utilQueryClustersYaml () {
  local -r clusters_path="${PLATFORM_PATH}/boilerplate/clusters.yaml"
  local -r helm_chart_dependencies_path="${PLATFORM_PATH}/boilerplate/hc-c-dependencies.yaml"
  local -r args=("$@")
  local -r query_name="${args[0]}"
  case "${query_name}" in
    "read-{region_name}-{cluster_name}-helm-charts-{dependency_name}-object")
      local -r region_name="${args[1]}"
      local -r cluster_name="${args[2]}"
      local -r dependency_name="${args[3]}"
      local -r dependency_obj=$( \
        # shellcheck disable=SC2016
        _region_name="${region_name}" \
        _cluster_name="${cluster_name}" \
        _dependency_name="${dependency_name}" \
        _chart_name="${chart_name}" \
        yq '
          env(_region_name) as $region_name
          | env(_cluster_name) as $cluster_name
          | env(_dependency_name) as $dependency_name
          | env(_chart_name) as $chart_name
          | .regions[$region_name]
          | .clusters[$cluster_name].helm_charts
          | .dependencies[]
          | select(.name == $dependency_name)
          | .
        ' "${clusters_path}" \
      )
      echo "${dependency_obj}"
      ;;
    "read-{region_name}-{cluster_name}-helm-charts-{dependency_name}-{chart_name}-object")
      local -r region_name="${args[1]}"
      local -r cluster_name="${args[2]}"
      local -r dependency_name="${args[3]}"
      local -r chart_name="${args[4]}"
      local -r chart_obj=$( \
        # shellcheck disable=SC2016
        _region_name="${region_name}" \
        _cluster_name="${cluster_name}" \
        _dependency_name="${dependency_name}" \
        _chart_name="${chart_name}" \
        yq '
          env(_region_name) as $region_name
          | env(_cluster_name) as $cluster_name
          | env(_dependency_name) as $dependency_name
          | env(_chart_name) as $chart_name
          | .regions[$region_name]
          | .clusters[$cluster_name].helm_charts
          | .dependencies[]
          | select(.name == $dependency_name)
          | .charts[]
          | select(.name == $chart_name)
          | .
        ' "${clusters_path}" \
      )
      echo "${chart_obj}"
      ;;
    # TODO:
    #   - maybe catch the error here, if region_name or cluster_name are
    #     missing in the argument or yq can't find it.
    #
    # NOTE:
    #   - it doesn't return .helm_charts prop.
    #
    # RETURN:
    #   - returns {"active": ..., ..., "cloud": ...}
    #
    "read-{region_name}-{cluster_name}-configs")
      local -r region_name="${args[1]}"
      local -r cluster_name="${args[2]}"

      # shellcheck disable=SC2016
      _region_name="${region_name}" \
      _cluster_name="${cluster_name}" \
      yq \
        '
          env(_region_name) as $region_name
          | env(_cluster_name) as $cluster_name
          | .regions[$region_name].clusters[$cluster_name]
          | del(.helm_charts)
          | .
        ' "${clusters_path}"
      ;;
    "read-{region_name}-{cluster_name}-configs-prop")
      local -r cluster_configs="${args[1]}"
      local -r prop_name="${args[2]}"

      # shellcheck disable=SC2016
      _cluster_configs="${cluster_configs}" \
      _prop_name="${prop_name}" \
      yq \
        -n \
        '
          env(_cluster_configs) as $cluster_configs
          | env(_prop_name) as $prop_name
          | $cluster_configs[$prop_name]
        '
      ;;
    # Get regions name
    # NOTE:
    #   - return names ONLY if a region has data and clusters data.
    #     Example: it will not return data if a property is `europe: {}`
    "get-regions-name")
      local -a arr=()
      while IFS= read -r value; do
        arr+=("${value}")
      done < <( \
        yq \
          -r '
            .regions
            | del(.. | select(tag == "!!map" and length == 0))
            | .
            | keys
            | .[]
          ' "${clusters_path}" \
      )
      echo "${arr[@]}"
      ;;
    # Get clusters name.
    # NOTE:
    #   - return names ONLY if a region has data and clusters data.
    #     Example: it will not return data if a property is `europe: {}` AND
    #     `{..., europe: {clusters: {}, ...}`
    "get-{region_name}-clusters-name")
      local -r region_name="${args[1]}"
      local -a arr=()
      # shellcheck disable=SC2016
      while IFS= read -r value; do
        arr+=("${value}")
      done < <( \
        _region_name="${region_name}" \
        yq '
          env(_region_name) as $region_name
          | .regions[$region_name].clusters
          | del(.. | select(tag == "!!map" and length == 0))
          | .
          | keys
          | .[]
        ' "${clusters_path}" \
      )
      echo "${arr[@]}"
      ;;
    "get-{region_name}-{cluster_name}-helm-charts-dependencies")
      local -r region_name="${args[1]}"
      local -r cluster_name="${args[2]}"
      # shellcheck disable=SC2016
      _region_name="${region_name}" \
      _cluster_name="${cluster_name}" \
      yq \
        '
          .regions[env(_region_name)]
          | .clusters[env(_cluster_name)]
          | .helm_charts.dependencies
          | .
        ' "${clusters_path}"
      ;;
    "get-{region_name}-{cluster_name}-dependencies-name")
      local -r region_name="${args[1]}"
      local -r cluster_name="${args[2]}"
      local -r dependencies=$( \
        # shellcheck disable=SC2016
        _region_name="${region_name}" \
        _cluster_name="${cluster_name}" \
        yq '
          env(_region_name) as $region_name
          | env(_cluster_name) as $cluster_name
          | .regions[$region_name]
          | .clusters[$cluster_name].helm_charts
          | .dependencies[].name
        ' "${clusters_path}" \
      )
      local -a arr=("${dependencies[@]}")
      echo "${arr[@]}"
      ;;
    "get-{region_name}-{cluster_name}-{dependencies_name}-charts-name")
      local -r region_name="${args[1]}"
      local -r cluster_name="${args[2]}"
      local -r dependency_name="${args[3]}"
      local -r charts=$( \
        # shellcheck disable=SC2016
        _region_name="${region_name}" \
        _cluster_name="${cluster_name}" \
        _dependency_name="${dependency_name}" \
        yq '
          env(_region_name) as $region_name
          | env(_cluster_name) as $cluster_name
          | env(_dependency_name) as $dependency_name
          | .regions[$region_name]
          | .clusters[$cluster_name].helm_charts
          | .dependencies[]
          | select(.name == $dependency_name)
          | .charts[].name
        ' "${clusters_path}" \
      )
      local -a arr=("${charts[@]}")
      echo "${arr[@]}"
      ;;
    "get-{region_name}-{cluster_name}-{dependency_name}-{chart_name}-prop")
      local -r obj="${args[1]}"
      local -r prop="${args[2]}"
      local output_type="${args[3]}" # use incase we need to use jq with the output
      # default
      if [ -z "${output_type}" ]; then
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
      ;;
    "read-{region_name}-{cluster_name}-helm-charts-{dependency_name}-{chart_name}")
      local -r region_name="${args[1]}"
      local -r cluster_name="${args[2]}"
      local -r dependency_name="${args[3]}"
      local -r chart_name="${args[4]}"

      # shellcheck disable=SC2016
      _region_name="${region_name}" \
      _cluster_name="${cluster_name}" \
      _dependency_name="${dependency_name}" \
      _chart_name="${chart_name}" \
      yq \
        '
          .regions[env(_region_name)]
          | .clusters[env(_cluster_name)]
          | .helm_charts.dependencies[]
          | select(.name == env(_dependency_name))
          | .repository as $repository
          | .charts[]
          | select(.name == env(_chart_name))
          | .dependency_name |= env(_dependency_name)
          | .repository |= $repository
          | .
        ' "${clusters_path}"
      ;;
    "post-{region_name}-{cluster-name}-helm-charts-dependencies")
      local -r region_name="${args[1]}"
      local -r cluster_name="${args[2]}"
      local -r helm_chart_dependencies_yaml_to_json=$( \
        yq \
          -o "json" \
          '
            .
          ' "${helm_chart_dependencies_path}" \
      )

      local -r clusters_yaml_to_json=$( \
        yq \
          -o "json" \
          '
            .
          ' "${clusters_path}" \
      )
      # TODO
      # - Maybe only add the missing charts. from dependencies to clusters.yaml
      # - must update the object except the version of clusters.yaml. that version
      #   should be the repo chart.yaml version.
      #   only allow the obj so be set in North America dev.
      #   for other region dev Copy from North America.
      local -r new_clusters_yaml=$(\
        echo "${clusters_yaml_to_json}" |
          jq \
            --argjson obj "${helm_chart_dependencies_yaml_to_json}" \
            --arg region_name "${region_name}" \
            --arg cluster_name "${cluster_name}" \
            '
              (

                .regions[$region_name]
                | .clusters[$cluster_name]
                | .helm_charts
              ) |= (
                if ((. | type) != "object") then
                  . = $obj
                end
              )
              | .
            ' | yq -P '.' \
      )
      # shellcheck disable=SC2016
      _new_cluster_yaml="${new_clusters_yaml}" \
      _region_name="${region_name}" \
      _cluster_name="${cluster_name}" \
      yq -i '
        env(_new_cluster_yaml)
        | .
        | (
          .regions[env(_region_name)]
          | .clusters[env(_cluster_name)]
          | (.helm_charts | key ) line_comment="Do NOT edit manually. User boilerplace to update .helm_charts value."
        ) |= .
      ' "${clusters_path}"
      ;;
    # TODO:
    #   - Commented the line that adds a comment to .release, when array is
    #     empty, it puts the comment before `[]`, causing yq to fail with
    #     error. Find out how to fix it where we can add a comment after the
    #     bracket.
    # NOTE
    #   - `releases` arg is stringified. should never be passed as empty string.
    #     Other functions should send null.
    "put-{region_name}-{cluster_name}-{dependency_name}-{chart_name}-to-latest-version")
      local -r region_name="${args[1]}"
      local -r cluster_name="${args[2]}"
      local -r dependency_name="${args[3]}"
      local -r chart_name="${args[4]}"
      local -r latest_version="${args[5]}"
      local -r releases="${args[6]}"
      local -r is_up_to_date="${args[7]}"

      # | (.releases | key) line_comment="DESCRIPTION: Releases history. Must be >= .version. IMPORTANT: Do NOT edit this property (key/values) manually. Use boilerplate repo to get new releases."
      # shellcheck disable=SC2016
      _region_name="${region_name}" \
      _cluster_name="${cluster_name}" \
      _dependency_name="${dependency_name}" \
      _chart_name="${chart_name}" \
      _latest_version="${latest_version}" \
      _releases="${releases}" \
      _is_up_to_date="${is_up_to_date}" \
      yq \
        -r \
        -P \
        '
          env(_region_name) as $_region_name
          | env(_cluster_name) as $_cluster_name
          | (env(_releases) | type) as $_releases_type
          | .regions[$_region_name]
          | .clusters[$_cluster_name]
          | .helm_charts
          | .dependencies[]
          | select(.name == env(_dependency_name))
          | .charts[]
          | select(.name == env(_chart_name))
          | .latest_version |= env(_latest_version)
          | .latest_version line_comment="DESCRIPTION: Latest version of the helm-chart. IMPORTANT: Do NOT edit this property (key/values) manually. Use boilerplate repo to get the latest version."
          | with(select($_releases_type == "!!str");
              .releases = (env(_releases) | split(" ") | reverse)
            )
          | with(select($_releases_type == "!!null");
              .releases = []
            )
          | .is_up_to_date |= env(_is_up_to_date)
          | .is_up_to_date line_comment="DESCRIPTION: Check if chart is up-to-date. IMPORTANT: Do NOT edit this property (key/values) manually. Use boilerplate repo to update the value."
          | .
        ' "${clusters_path}"
          # | .releases = env(_releases) == null
        # | with(env(_releases) == null;
        #   )
        #   | with(env(_releases) != null;
        #     .releases = (env(_releases) | split(" "))
        #   )
      ;;
    # TODO:
    #   - Consider creating a function since functions doesn't return an output.
    "put-{region_name}-{cluster_name}-{dependency_name}-{chart_name}-object")
      local -r region_name="${args[1]}"
      local -r cluster_name="${args[2]}"
      local -r dependency_name="${args[3]}"
      local -r chart_name="${args[4]}"
      local -r obj="${args[5]}"
      # shellcheck disable=SC2016
      _region_name="${region_name}" \
      _cluster_name="${cluster_name}" \
      _dependency_name="${dependency_name}" \
      _chart_name="${chart_name}" \
      _obj="${obj}" \
      yq \
        -P \
        -ri \
        '
          env(_region_name) as $_region_name
          | env(_cluster_name) as $_cluster_name
          | (
            .regions[$_region_name]
            | .clusters[$_cluster_name]
            | .helm_charts
            | .dependencies[]
            | select(.name == env(_dependency_name))
            | .charts[]
            | select(.name == env(_chart_name))
          ) = env(_obj)
          | .
        ' "${clusters_path}"
      ;;
    *)
      echo "false"
      ;;
  esac
}
