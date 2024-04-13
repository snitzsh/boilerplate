#!/bin/bash

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
