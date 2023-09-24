#!/bin/bash

#
# TODO:
#  - implement vervose output.
#
# NOTE:
#   - https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
#   - https://en.wikipedia.org/wiki/ANSI_escape_code
#     Black        0;30     Dark Gray     1;30
#     Red          0;31     Light Red     1;31
#     Green        0;32     Light Green   1;32
#     Brown/Orange 0;33     Yellow        1;33
#     Blue         0;34     Light Blue    1;34
#     Purple       0;35     Light Purple  1;35
#     Cyan         0;36     Light Cyan    1;36
#     Light Gray   0;37     White         1;37
#
# DESCRIPTION
#   - outputs stdout and stderr logs
#
# ARGS:
#   - $1 : level    : info | warn | error : type of log
#   - $2 : message  : any                 : error message
#   - $3 : source   : any                 : which function executed logger func
#
# RETURN
#   - STRING  : log
#   * example >
#   *   2023-06-11 11:16:40 - INFO - Removed 16 files - syncHelmModulesFileNames
#
function logger () {
  local _time
  _time=$(date -u +"%Y-%m-%d %T")
  local color="31"
  case $1 in
    "INFO")
      color="34"
      ;;

    "WARN")
      color="33"
      ;;

    "ERROR")
      color="31"
      ;;

    *)
      color="31"
      ;;
  esac
  echo -e "${_time} - \033[${color}m ${1} \033[0m - ${2} - ${3}"
}
