#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - null
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
utilHelmChartUpdateIgnoreFile () {
  local -r func_name="${FUNCNAME[0]}"
  local -r args=("$@")
  local -r query_name="${args[0]}"
  local -r dependency_name="${args[1]}"
  local -r chart_name="${args[2]}"
  # local -r file_dependency="${args[5]}"

  if [ -f "${query_name}" ]; then
    case "${query_name}" in
      ".helmignore")
        local -ar files=( \
          "./charts" \
          "Chart.lock" \
        )
        local file_found=""
        found=$(find . \
          -name "${query_name}" \
          -type f \
          -exec grep \
          -iFx ".vscode/" {} \;
        )
        echo "${found}"
        
        ;;
      ".gitignore")
        # IMPORTANT:
        # - Always make sure to check the file directly to make sure nothing has changed.
        # Add more files here...
        local -ar files=( \
          "# --- START AUTOMATED ---" \
          "# --- note: Do NOT add manually! If you want to add more files to ignore, use boilerplate function ${func_name}. ---" \
          "charts" \
          "Chart.lock" \
          "# --- END AUTOMATED ---" \
        )

        delete_text_reg=$(_generateRegex "${files[@]}")
        # Use this command to test when supporting linux:
        # sed -E "/$delete_text_reg/d" "./output.txt"
        # NOTE: '.bak' is a work around for MacOS using sed.
        sed -i'.bak' -E "/$delete_text_reg/d" ".gitignore"
        rm "${query_name}.bak"

        # sleep 5
        local file_found=""
        for _file in "${files[@]}"; do
          file_found=$(find . \
            -name "${query_name}" \
            -type f \
            -exec grep \
            -iFx "${_file}" {} \;
          )
          if [ "${file_found}" == "" ]; then
            echo "${_file}" >> "${query_name}"
          fi
          # In case git is tracking the file already. It removes it as a fallback.
          # if [[ "${_file}" != \#* ]]; then
            # git rm -q -r --cached ./*/*/"${_file}"
          # fi
        done
        # Git
        local -a args_2=( \
          "${func_name}" \
          "Updated chart's dependencies for ${dependency_name}/${chart_name}." \
          "Updated chart '${dependency_name}/${chart_name}'s ${query_name} file." \
        )
        utilGitter "${args_2[@]}"
        ;;
      *)
        ;;
    esac
  fi
}

_generateRegex () {
  local -a arr=("$@")
  # /^\B(.*)START[\w\W]*---$
  # local reg_="^(?!({<[line]>})$).*$" # curly bracket is a `placeholder` for dynamic replace.
  local reg_="^({})$" # curly bracket is a `placeholder` for dynamic replace.
  local pattern=""
  # local files_count="${#arr[@]}"
  local last_index=$(( ${#arr[*]} - 1 ))
  local last_item="${arr[$last_index]}"

  for item in "${arr[@]}"; do
    pattern+="${item}"
    if [ "${item}" != "${last_item}" ]; then
      pattern+="|"
    fi
  done
  # echo "${reg_}" | sed "s/{}/$pattern/"
  echo "${reg_//\{\}/$pattern}"
}
