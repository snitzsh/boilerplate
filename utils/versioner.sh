#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - A version like `v0.0.0` aren't semantic, but is common to used 'v'
#     for versioning. Ex: `git` uses `v0.0.0` versioning.
#   - The first if-statemnt checks for v0.0.0
#        then 0.0.0
#        then 0.0.0-beta-1
#     The reason for this if- statement order is because semver regex and v_v_v
#     regex will return true for 0.0.0, so it's better for semver regex to
#     be the last check.
#
#   - note that scan in jq throw a silent error which causes jq not to output
#     anything (not even the default object). The work around is
#     adding [EXP?] is return null.
# DESCRIPTION:
#   - Validates a version, it can be use for helm chart or other software.
#     by using 3 regexes.
#
# ARGS:
#   - $1 : version : 0.0.0 | v0.0.0 | 3.1.0-beta.2 (rare) | chart version
#
# RETURN:
#   - OBJECT : {}
#
utilVersionerGetVersionAsObj () {
  local -r version="${1}"
  jq \
    -nr \
    --arg regex_x_x_x "${PLATFORM_REGEX_X_X_X}" \
    --arg regex_v_x_x_x "${PLATFORM_REGEX_V_X_X_X}" \
    --arg regex_semver "${PLATFORM_REGEX_SEMVER}" \
    --arg regex_extract_x_x_x "${PLATFORM_REGEX_EXTRACT_X_X_X}" \
    --arg version "${version}" \
    '
      $version | test($regex_x_x_x) as $is_valid_x_x_x
      | $version | test($regex_v_x_x_x) as $is_valid_v_x_x_x
      | $version | test($regex_semver) as $is_valid_semver
      | [$version | scan($regex_extract_x_x_x; "n")?] as $x_x_x
      | {
          "is_valid": false,
          "type": null,
          "x_x_x_str": null,
          "x_x_x_num": null
        } as $obj
      | $obj
      | .
      | if ($is_valid_x_x_x) then
          .is_valid |= $is_valid_x_x_x
          | .type |= "x_x_x"
          | .x_x_x_str |= ($x_x_x | .[])
        else
          if ($is_valid_v_x_x_x) then
            .is_valid |= $is_valid_v_x_x_x
            | .type |= "v_x_x_x"
            | .x_x_x_str |= ($x_x_x | .[])
          else
            if ($is_valid_semver) then
              .is_valid |= $is_valid_semver
              | .type |= "semver"
              | .x_x_x_str |= ($x_x_x | .[])
            end
          end
        end
      | if (.x_x_x_str==null) then
          .x_x_x_str |= []
        else
          .x_x_x_num |= (
            $x_x_x[] | [(.[0] | tonumber), (.[1] | tonumber), (.[2] | tonumber)]
          )
        end
      | .
    '
}

#
# TODO:
#   - null
#
# NOTE:
#   - Only handles flat json, not deep json
#
# DESCRIPTION:
#   - Return key's value based, where `query` is the name of the key
#
# ARGS:
#   - $1 : STRING : <[any key name of the object returned by function utilVersionerGetVersionAsObj]>
#   - $2 : OBJECT : <[object returned by function utilVersionerGetVersionAsObj]>
#
# RETURN:
#   - ANY : <[key's value of the object returned by function utilVersionerGetVersionAsObj]> : true | false | []
#
utilVersionerIsVersionObjQuery () {
  local -r query="${1}"
  local -r obj="${2}"
  jq \
    -nr \
    --arg query "${query}" \
    --argjson obj "${obj}" \
    '
      $obj
      | .[$query]
    '
}

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
#   - Compare version for helm-charts.
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

#
# TODO:
#   - add args and better description.
#
# NOTE:
#   - Cannot have nothing older then version (deployed version).
#
# DESCRIPTION:
#   - Cleans up the .releases[] we try to fetch a new version.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
utilVersionerCleanUpReleasesProp () {
  local -r func_name="${FUNCNAME[0]}"
  local -r releases="${1}"
  local -r version="${2}"
  local -a arr=()
  local -a cleaned_releases=()

  # obj
  local -r version_obj=$( \
    utilVersionerGetVersionAsObj "${version}" \
  )
  # is_valid
  local -r version_is_valid=$( \
    utilVersionerIsVersionObjQuery "is_valid" "${version_obj}"
  )
  # validates
  if [ "${version_is_valid}" == "false" ]; then
    logger "ERROR" "Version: '${version}' is not valid. Please check if you modified the version manually by mistake." "${func_name}"
    exit 1
  fi

  local -r version_x_x_x_num=$( \
    utilVersionerIsVersionObjQuery "x_x_x_num" "${version_obj}"
  )

  while IFS= read -r value; do
    arr+=("${value}")
  done < <( \
    jq \
      -nr \
      --argjson releases "${releases}" \
      '
        $releases
        | .[]
      ' \
  )

  local item_version_obj=""
  local item_version_is_valid=""
  local item_version_x_x_x_num=""
  local is_item_version_greater_than_version=""

  for i in "${arr[@]}"; do
    # Obj
    item_version_obj=$( \
      utilVersionerGetVersionAsObj "${i}" \
    )
    # is_valid
    item_version_is_valid=$( \
      utilVersionerIsVersionObjQuery "is_valid" "${item_version_obj}"
    )
    # validates
    if [ "${item_version_is_valid}" == "false" ]; then
      logger "ERROR" "Item version: '${i}' is not valid. Please check if you modified the version manually by mistake." "${func_name}"
      exit 1
    fi
    # formatted
    item_version_x_x_x_num=$( \
      utilVersionerIsVersionObjQuery "x_x_x_num" "${item_version_obj}"
    )
    # compare
    is_item_version_greater_than_version=$( \
      utilVersionerCompareVersions \
        "greater_than" \
        "${item_version_x_x_x_num}" \
        "${version_x_x_x_num}" \
    )

    if [ "${is_item_version_greater_than_version}" == "true" ]; then
      cleaned_releases+=("${i}")
    fi
  done

  # It's hard to make jq accept a bash array. so this a work around.
  printf '%s\n' "${cleaned_releases[@]}" \
    | jq -R '.' \
      | jq \
          -s \
          '
            .
            | if ( (. | type) != "array" ) then
                . = []
              end
            | map(select(length > 0))
          '
}
