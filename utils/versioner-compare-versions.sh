#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - It assumes the ${2} and ${3} argument values already were validated
#     by utilVersionerGetVersionAsObj.
#   - It assumes ${2} could be greater than ${3}.
#   - returns error if query is unknown.
#
# DESCRIPTION:
#   - Compare version for helm-charts-configs.
#
# ARGS:
#   - ${1} : STRING : "greater_than" | "less_than" | "equals"
#   - ${2} : ARRAY  : [0, 0, 0]
#   - ${3} : ARRAY  : [0, 0, 0]
#
# RETURN:
#   - BOOLEAN : true | false
#
utilVersionerCompareVersions () {
  local -r query="${1}"
  local -r a_version_x_x_x_num="${2}"
  local -r b_version_x_x_x_num="${3}"

  jq \
    -nr \
    --arg query "${query}" \
    --argjson a_version_x_x_x_num "${a_version_x_x_x_num}" \
    --argjson b_version_x_x_x_num "${b_version_x_x_x_num}" \
    '
      $a_version_x_x_x_num[0] as $a_version_major
      | $a_version_x_x_x_num[1] as $a_version_minor
      | $a_version_x_x_x_num[2] as $a_version_patch
      | $b_version_x_x_x_num[0] as $b_version_major
      | $b_version_x_x_x_num[1] as $b_version_minor
      | $b_version_x_x_x_num[2] as $b_version_patch
      | {
          output: false
        } as $obj
      | $obj
      | if ($query == "greater_than") then
          if ($a_version_major > $b_version_major) then
            .output |= true
          else
            if (
              ($a_version_major == $b_version_major) and
              ($a_version_minor > $b_version_minor)
            ) then
              .output |= true
            else
              if (
                ($a_version_major == $b_version_major) and
                ($a_version_minor == $b_version_minor) and
                ($a_version_patch > $b_version_patch)
              ) then
                .output |= true
              end
            end
          end
        elif ($query == "less_than") then
          if ($a_version_major < $b_version_major) then
            .output |= true
          else
            if (
              ($a_version_major == $b_version_major) and
              ($a_version_minor < $b_version_minor)
            ) then
              .output |= true
            else
              if (
                ($a_version_major == $b_version_major) and
                ($a_version_minor == $b_version_minor) and
                ($a_version_patch < $b_version_patch)
              ) then
                .output |= true
              end
            end
          end
        elif ($query == "equals") then
          if (
            ($a_version_major == $b_version_major) and
            ($a_version_minor == $b_version_minor) and
            ($a_version_patch == $b_version_patch)
          ) then
            .output |= "true"
          end
        else
          error("Unknown query [" + $query + "]")
        end
      | .output
    '
}

