#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Update the helm-chart version if it meets this criteria:
#     1) values.yaml has `.<[chart-name]>` prop
#     2) cluster.yaml has the same .version with what the repo have.
#        if not, then must check manually.
#     3) .version is < cluster.latest_version
#     4) if yaml merge to the new version is successfull
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
funcHelmChartUpdateVersion () {
  local -r func_name="${FUNCNAME[0]}"
  local -r args=("$@")
  local -r dependency_name="${args[0]}"
  local -r chart_name="${args[1]}"
  local -r region_name="${args[2]}"
  local -r cluster_name="${args[3]}"
  local -r file_dependency="${args[4]}"

  if [ -f "./Chart.yaml" ] && [ -f "./values.yaml" ]; then
    echo "${chart_name}"
    # echo "${file_dependency}" | yq '.'
    # ls
    # cat .helmignore
    # grep -qxF 'NoDisplay=true' '.helmignore'
    # sed -i '/NoDisplay=true/!s/$/\nNoDisplay=true/' .helmignore

    # grep -Fx will match the exact text per line.
    found=$(find . \
      -name ".helmignore" \
      -type f \
      -exec grep \
      -iFx ".vscode/" {} \;
    )
    echo "Found: ${found}"
  fi
}
