#!/bin/bash

#
# TODO:
#   - fix issue: with line 157: arr: bad array subscript
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
function _utilGenerateRegex () {
  local -a arr=("$@")
  # /^\B(.*)START[\w\W]*---$
  # local reg_="^(?!({<[line]>})$).*$" # curly bracket is a `placeholder` for dynamic replace.
  local reg_="^({})$" # curly bracket is a `placeholder` for dynamic replace.
  local pattern=""
  # local files_count="${#arr[@]}"
  local last_index=$(( ${#arr[*]} - 1 ))
  local last_item="${arr[$last_index]}"

  for item in "${arr[@]}"; do
    if [ -n "${item}" ]; then
      pattern+="${item}"
      if [ "${item}" != "${last_item}" ]; then
        pattern+="|"
      fi
    fi
  done
  # echo "${reg_}" | sed "s/{}/$pattern/"
  echo "${reg_//\{\}/$pattern}"
}
