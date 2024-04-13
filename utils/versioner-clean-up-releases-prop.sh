#!/bin/bash

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