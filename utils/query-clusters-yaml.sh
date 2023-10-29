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
    "get-dependency")
      echo "true"
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
    "get-{region_name}-{cluster-name}-helm-charts")
        yq \
          '
            .regions
          ' "${clusters_path}"
      ;;
    "post-{region_name}-{cluster-name}-helm-charts-dependencies")
      local -r region_name="${args[1]}"
      local -r cluster_name="${args[2]}"
      helm_chart_dependencies_yaml_to_json=$( \
        yq \
          -o "json" \
          '
            .
          ' "${helm_chart_dependencies_path}" \
      )

      clusters_yaml_to_json=$( \
        yq \
          -o "json" \
          '
            .
          ' "${clusters_path}" \
      )

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
                . = {}
              end
              | . |= $obj
            )
            | .
          ' | yq -P '.'

      # _region_name="${region_name}" \
      # _cluster_name="${cluster_name}" \
      # yq \
      #   '
      #     env(_region_name) as $_region_name
      #     | env(_cluster_name) as $_cluster_name
      #     | .regions[$_region_name]
      #     | .clusters[$_cluster_name]
      #     | .
      #   ' "${clusters_path}"
      ;;
    *)
      echo "false"
      ;;
  esac
}

