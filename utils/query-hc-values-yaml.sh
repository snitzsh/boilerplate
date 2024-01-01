#!/bin/bash

#
# TODO:
#   - maybe use this function in funcHelmChartPostChart.
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Querie file for CRUD properties on `helm-charts/<dependency_name>/<[chart_name]>/<[region_name]>/<[cluster_name]>/values.yaml`
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
utilQueryHelmChartValuesYaml () {
  local -r _path="${PLATFORM_PATH}/helm-charts/"
  local -r args=("$@")
  local -r query_name="${args[0]}"
  local -r dependency_name="${args[1]}"
  local -r chart_name="${args[2]}"
  # local -r chart_name="argo-workflows"
  local -r region_name="${args[3]}"
  local -r cluster_name="${args[4]}"
  local -r func_name="${args[5]}"
  local -r values_path="${_path}/${dependency_name}/${chart_name}/${region_name}/${cluster_name}/values.yaml"

  # NOTE: Any argument after index 4, will be specific per query.
  case "${query_name}" in
    "create-common-props")
      local -r cluster_type="${args[6]}"
      local -r managed_by="${args[7]}"
      local -r use_helm_hooks="${args[8]}"
      local -r dependencies="${args[9]}"
      # shellcheck disable=SC2016
      _dependency_name="${dependency_name}" \
      _chart_name="${chart_name}" \
      _region_name="${region_name}" \
      _cluster_name="${cluster_name}" \
      _func_name="${func_name}" \
      _cluster_type="${cluster_type}" \
      _managed_by="${managed_by}" \
      _use_helm_hooks="${use_helm_hooks}" \
      _dependencies="${dependencies}" \
      _platform="${PLATFORM}" \
      _ssh_repository_endpoint="${SSH_REPOSITORY_ENDPOINT}" \
      yq \
        -ri \
        '
          env(_dependency_name) as $_dependency_name
          | env(_chart_name) as $_chart_name
          | env(_region_name) as $_region_name
          | env(_cluster_name) as $_cluster_name
          | env(_func_name) as $_func_name
          | env(_cluster_type) as $_cluster_type
          | env(_managed_by) as $_managed_by
          | env(_use_helm_hooks) as $_use_helm_hooks
          | env(_dependencies) as $_dependencies
          | env(_platform) as $_platform
          | env(_ssh_repository_endpoint) as $_ssh_repository_endpoint
          | ("DO NOT manually update this value. This property was initially auto generated by {_func_name} in boilerplate repository." | sub("{_func_name}", $_func_name)) as $key_comment
          | "DO NOT manually update this value. This property was initially auto generated by funcHelmChartUpdateValuesAddDependencyNameAsProperty in boilerplate repository." as $chart_comment
          | .
          | with(.["main"];
              .nameOverride = ""
              | .fullnameOverride = ""
              | .cluster_type = $_cluster_type
              | .region_name = $_region_name
              | .cluster_name = $_cluster_name
              | .ssh_repository_endpoint = $_ssh_repository_endpoint
              | .managed_by = $_managed_by
              | .use_helm_hooks = $_use_helm_hooks
              | .dependencies = $_dependencies
            )
          | {$_chart_name: .[$_chart_name]} as $chart_values
          | del(.[$_chart_name])
          | . as $root
          | with($root;
              . |= . *+ $chart_values
            )
          | $root
          | . head_comment="-----------------------------------------------------------------------\nDO NOT DELETE this comment!\nThis file was generate by " + $_func_name + " in boilerplate repo.\n#\nYou can reference all the values in ./versions/values/x.x.x.yaml file.\n#\nNOTE: Other cmd will put this values in merge it in ./values.yaml.\n-----------------------------------------------------------------------"
          | (.["main"].cluster_type | key) linecomment=$key_comment
          | (.["main"].region_name | key) linecomment=$key_comment
          | (.["main"].cluster_name | key) linecomment=$key_comment
          | (.["main"].ssh_repository_endpoint | key) linecomment=$key_comment
          | (.["main"].managed_by | key) linecomment=$key_comment
          | (.["main"].use_helm_hooks | key) linecomment=$key_comment
          | (.[$_chart_name] | key) headComment=$chart_comment
          | .
        ' "${values_path}"
      ;;
    "create-argo-cd-props")
      # _dependency_name="${dependency_name}" \
      # _chart_name="${chart_name}" \
      # _region_name="${region_name}" \
      # _cluster_name="${cluster_name}" \
      echo ""
      ;;
    *)
      echo "false"
      ;;
  esac
}
