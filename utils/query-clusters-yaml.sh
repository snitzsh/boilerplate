#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - if ${1} is not specified it return "false"
#
# DESCRIPTION:
#   - Queries the file clusters.yaml file.
#
# ARGS:
#   - ${1} : STRING :  "query_name"           : name of the query specified in `case` statement
#   - ${2} : ANY    :  ("a", "b") | "a" | 1   : incase the query needs an argument. Example: a query
#                                             : may need an argument to get data for specific region.
#
# RETURN:
#   - Array | Boolean : ("name1" "name2") | "false"
#
utilQueryClustersYaml () {
  local -r clusters_path="${SNITZSH_PATH}/boilerplate/clusters.yaml"
  local -r helm_chart_dependencies_path="${SNITZSH_PATH}/boilerplate/helm-chart-dependencies.yaml"
  local -r args=("$@")
  local -r query_name="${args[0]}"
  case "${query_name}" in
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
    "get-{region_name}-{cluster-name}-helm-charts-{dependency_name}-{chart_name}")
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
    *)
      echo "false"
      ;;
  esac
}

