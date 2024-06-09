#!/bin/bash

#
# TODO:
#   - support -n arguments
#   - support '[]' or '{}' arguments
#   - if expected argument is not passed set a default to all, ex:
#     --clusters=...,cluster_2,cluster_3,...
#
# NOTE:
#   - the first item return is the command (a.k.a query_name)
#   - not all characters are supporters as argument value. currently only
#     -, are known characters(it can be more)
#   - it doesn't currently the .arg return does not include `--` (--arg-1=a).
#     it returns it like like this: {arg: arg, ...}
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
function utilArgsParser () {
  local -a args=("$@")
  # shellcheck disable=SC2016
  _args="${args[*]}" \
  yq \
    -n \
    '
      env(_args) as $_args
      | (
          $_args
          | split(" --")
          | .[0]
          | [{
              "arg": "query-name",
              "value": .,
              "init": "--query-name"
            }]
        ) as $cmd
      | [(
          ($_args | match("(?:--([\w-]+)|-([a-zA-Z]))\s*(?:=\s*|\s+)([^\s,]+(?:,[^\s,]+)*)"; "g")) as $result
          | $result.string as $result_string
          | $result_string
          | . | match("-{1,2}([\w-]+)\s*(?:=\s*)?(.+)", "g")
          | {
              "arg": .captures[0].string,
              "value": (.captures[1].string | trim),
              "init": ($result_string | trim)
            }
        )] as $flags
      | $cmd + $flags
    '
      # | . + $flags
}
