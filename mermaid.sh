#!/bin/bash
# shellcheck source=/dev/null
# source "utils/source-utils.sh"

function handleCmds () {
  local -a func_names=($@)
  local new_dir=""
  local -r output_file="mermaid.yaml"

  # echo "Number of functions to scan: ${#func_names[@]}"

  for _dir in */; do
    new_dir="${_dir%/}"
    if [[ "${new_dir}" == "cmds-"* ]]; then
      # shellcheck disable=SC2016
      key="${new_dir}" \
      yq \
        -r \
        '
          env(key) as $key
          | if has($key) | not then .[$key] = {} else . end
        ' "${output_file}"

      # jq \
      #   -n \
      #   --arg key "${new_dir}" \
      #   '
      #     {"main": {}} as $obj
      #     | $obj
      #     | if (.main | has($key) | not) then
      #         $obj.main[$key] = {}
      #       end
      #     | .
      #   '
      #   sleep 1

      # if [ ! -f "${output_file}" ]; then
      # fi
    fi

    # echo "${_dir}"
  done
}

# NOTES:
#   - main.sh will execute dynamically based on argument, so there is not a
#     predictive way to follow which executes next.
#     The only way to predict is that cmds-* executes first.
#
# STEPS:
#   1) Find folders in currents directory
#   2) List file paths of each directory
#   3) Get function names of each file path
#   4) Loop on each file path to see where the functions are being executed.
#
function main () {
  # local -r func_n="${FUNCNAME[0]}"
  local -a _dirs=()
  local new_dir=""
  local -a project_func_names=()
  for _dir in */; do
    new_dir=$(echo "${_dir}" | sed 's/\///')
    # echo "${new_dir}"
    local -a folder_func_names=()
    while IFS= read -r file_path; do
      if [[ "$file_path" != *.sh ]]; then
        continue
      fi
      # Search for `function main () {...}` and `main () {...}`
      #   - Does not includes functions that are commented.
      local -a path_func_names=()
      while IFS= read -r func_name; do
        path_func_names+=("${func_name}")
      done < <(\
        sed -nE 's/^[[:space:]]*(function[[:space:]]+)?([[:alnum:]_]+)[[:space:]]*\(\).*/\2/p' "${file_path}"
      )
      if [[ "${#path_func_names[@]}" -gt 1 ]]; then
        # logger "WARN" "File ${file_path} contains ${#path_func_names[@]} function(s) defined. Consider creating a function per file." "${func_n}"
        echo "File ${file_path} contains ${#path_func_names[@]} function(s) defined. Consider creating a function per file."
      fi
      # Skips ./cmds-*
      if [[ "${#path_func_names[@]}" -eq 1 && "${file_path}" != "./cmds-"* ]]; then
        folder_func_names+=("${path_func_names[@]}")
      fi
      # TODO:
      # - make sure each function name is the name of the file. If not throw an error
      # echo "${path_func_names[@]}"
    done < <(\
      find "./${new_dir}" -type f
    )
    project_func_names+=("${folder_func_names[@]}")
  done

  handleCmds "${project_func_names[*]}"
}
# get anything inside... {} brackts
#  sed -n '/^function main () {/,/^}/p' main.sh
main
