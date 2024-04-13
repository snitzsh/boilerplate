#!/bin/bash
#
# STEPS:
#   1) Find folders in currents directory
#   2) List file paths of each directory
#   3) Get function names of each file path
#   4) Loop on each file path to see where the functions are being executed.
#
function main () {
  local -a _dirs=()
  local new_dir=""
  for _dir in */; do
    new_dir=$(echo "${_dir}" | sed 's/\///')
    echo "${new_dir}"
    while IFS= read -r file_path; do
      if [[ "$file_path" != *.sh ]]; then
        continue
      fi
      # Search for `function main () {...}` and `main () {...}`
      #   - Does not includes functions that are commented.
      local -a func_names=()
      while IFS= read -r func_name; do
        func_names+=("${func_name}")
      done < <(\
        sed -nE 's/^[[:space:]]*(function[[:space:]]+)?([[:alnum:]_]+)[[:space:]]*\(\).*/\2/p' "${file_path}"
      )
      if [[ "${#func_names[@]}" -gt 1 ]]; then
        echo "File ${file_path} contains more than one function defined. Consider creating a function per file."
      fi

    done < <(\
      find "./${new_dir}" -type f
    )
  done
}
# get anything inside... {} brackts
#  sed -n '/^function main () {/,/^}/p' main.sh
main
