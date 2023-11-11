#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - return error if something fails in the subshells.
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
utilGetFilesToIgnoreForHelmIgnore () {

  local -r current_helm_api_version=$( \
    yq -r '.apiVersion' Chart.yaml
  )
  # `test` chart files as string (not array)
  local test_helm_chart_files=""
  test_helm_chart_files=$(
    cd /tmp &&
    if [ -d "test/" ]; then
      rm -rf test/
    fi
    # silence the std and stderr, otherwise it shows as part of the file list.
    helm create test 1> /dev/null 2> /dev/null
    local test_helm_chart_file_2=""
    test_helm_chart_file_2=$(cd "test/" &&
      local -r new_helm_api_version=$( \
        yq -r '.apiVersion' Chart.yaml
      )
      local -a test_helm_chart_file_3=()
      # only returns something if it matches the same api version.
      if [ "${current_helm_api_version}" == "${new_helm_api_version}" ]; then
        # TODO:
        #  - never allow files to have spaces. else we are fucked!
        #    meaning that bash will threat name-with-spaces as a file per word.
        #  - maybe safeguard it with git hook before commit and/or of ci before PR is ready to merge.
        #
        test_helm_chart_file_3=("$(ls)")
      fi
      echo "${test_helm_chart_file_3[*]}"
    )
    echo "${test_helm_chart_file_2}"
  )
  # converts `test` chart files as array
  local -a test_helm_chart_files_arr=()
  while IFS= read -r value; do
      test_helm_chart_files_arr+=("${value}")
  done < <( \
    # shellcheck disable=SC2016
    _test_helm_chart_files="${test_helm_chart_files}" \
    yq \
      -rn \
      '
        env(_test_helm_chart_files) as $_test_helm_chart_files
        | $_test_helm_chart_files | split(" ")
        | .[]
      ' \
  )
  # List of current chart files
  local -a curret_chart_files=()
  while IFS= read -r value; do
      curret_chart_files+=("${value}")
  done < <( \
    ls
  )
  # NOTE:
  #   - the reason is adding Chart.lock and charts in these arrays, is because
  #     for local development there may be times where chart must be
  #     install to debug, causing the chart to create Charts.lock and charts,
  #     but should NOT be pushed to git. ArgoCD will take care to execute
  #     `helm dependency install` command internally so it doesn't need those
  #     folders at all.
  local -r files_to_ignore=$( \
    jq \
      -n \
      -r \
      --arg _test_helm_chart_files_arr "${test_helm_chart_files_arr[*]}" \
      --arg _chart_files "${curret_chart_files[*]}" \
      '
        $_test_helm_chart_files_arr | split(" ") as $test_files_arr
        | $_chart_files | split(" ") as $chart_files_arr
        | {
            "a": $test_files_arr,
            "b": $chart_files_arr
          } as $obj
        | $obj
        | if ((.a | index("Chart.lock") | type) != "number") then
            .a += ["Chart.lock"]
          end
        | if ((.a | index("charts") | type ) != "number") then
            .a += ["charts"]
          end
        | if ((.b | index("Chart.lock") | type) != "number") then
            .b += ["Chart.lock"]
          end
        | if ((.b | index("charts") | type ) != "number") then
            .b += ["charts"]
          end
        | .b - .a
        | .[]
      ' \
  )

  echo "${files_to_ignore}"
}
