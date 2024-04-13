#!/bin/bash

#
# TODO:
#   - Get all regex functions or reference in here...
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Multi-regex queries for specific situation.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#

function utilQueryRegexer () {
  local -ra args=("$@")
  local -r query_name="${args[0]}"
  local output="false"

  case "${query_name}" in
    "g-clone-repositories-get-repository-last-word")
      local app_name="${args[1]}" # App Name
      local repository="${args[2]}" # Repository name
      local repository_nickname_regex=".*${app_name}-([^[:space:]]+)$"
      local word_1=""
      if [[ $repository =~ $repository_nickname_regex ]]; then
        word_1="${BASH_REMATCH[1]}"
      else
        word_1="false"
      fi
      output="${word_1}"
      echo "$output"
      ;;
    *)
      ;;
  esac
}
