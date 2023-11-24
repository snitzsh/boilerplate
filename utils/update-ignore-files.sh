#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - make sure to add a emty line if it does NOT exist. Else it will return error.
#   - install sed gnu if compatible for linux/macOS, instead using macOS's
#     `poxis sed`
#     https://gist.github.com/andre3k1/e3a1a7133fded5de5a9ee99c87c6fa0d
#     https://medium.com/@bramblexu/install-gnu-sed-on-mac-os-and-set-it-as-default-7c17ef1b8f64#:~:text=We%20know%20that%20the%20sed,%5Cw%20%2C%20and%20%5Cb%20.
#   - ignore files incase sealsecrets is used incase secrets are store
#     locally. secrets should not expose in git. Probably a githook
#     is sufficient to prevent mistakes.
#   - add a reminded logger:
#       -> Always make sure to check the file directly to make sure nothing has
#          changed. Add more files here...
#          Example: maybe in helm apiVersion 3, Chart.lock is called Charty.lock
#          we should support this kind of migration.
#       -> Always make sure helm version is the same as or migrate to new
#          version.
#
# NOTE:
#   - takes care of repository level, and helm-chart level.
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
utilHelmChartUpdateIgnoreFiles () {
  local -r func_name="${FUNCNAME[0]}"
  local -r args=("$@")
  local -r query_name="${args[0]}"
  local -r dependency_name="${args[1]}"
  local -r chart_name="${args[2]}"
  local -r region_name="${args[3]}"
  local -r cluster_name="${args[4]}"
  # local -r file_dependency="${args[5]}"

  if [ -f "${query_name}" ]; then
    local proceed="true"
    local -a args_2=( \
      "${func_name}" \
    )
    local -a files=( \
      "# --- START AUTOMATED ---" \
      "# --- note: Do NOT add manually! If you want to add more files to ignore, use boilerplate function ${func_name}. ---" \
    )
    case "${query_name}" in
      ".gitignore")
        args_2+=(
          "Updated ${dependency_name}/${chart_name} ${query_name} file."
        )
        # IMPORTANT:
        # - Always make sure to check the file directly to make sure nothing has changed.
        # Add more files here...
        files=(
          "${files[@]}"
          "charts"
          "Chart.lock"
        )
        ;;
      ".helmignore")
        args_2+=(
          "Updated ${dependency_name}/${chart_name}/${region_name}/${cluster_name}'s ${query_name} file."
        )
        # TODO:
        #   - helmignore should not track any k8s object that is a secret.
        local -a files_to_ignore=()
        while IFS='' read -r line; do files_to_ignore+=("${line}"); done < <(
          utilGetFilesToIgnoreForHelmIgnore | yq -r 'split(" ") | .[]'
        )
        files=(
          "${files[@]}"
          "${files_to_ignore[@]}"
        )
        ;;
      *)
        proceed="false"
        ;;
    esac

    if [ "${proceed}" == "true" ]; then
      files=(
        "${files[@]}"
        "# --- END AUTOMATED ---"
      )
      local -a lines_to_delete=()
      while IFS='' read -r line; do lines_to_delete+=("${line}"); done < <(
        # TODO: find out if you get pass string to awk
        awk '/# --- START AUTOMATED ---/,/# --- END AUTOMATED ---/' "${query_name}"
      )
      local lines_to_delete_regex
      lines_to_delete_regex=$(_utilGenerateRegex "${lines_to_delete[@]}")

      # Use this command to test when supporting linux:
      # sed -E "/$lines_to_delete_regex/d" "./output.txt"
      # NOTE: '.bak' is a work around for MacOS using sed.
      sed -i'.bak' -E "/$lines_to_delete_regex/d" "${query_name}"
      rm "${query_name}.bak"

      local file_found=""
      local file_path=""
      for _file in "${files[@]}"; do
        file_found=$( \
          find . \
            -name "${query_name}" \
            -type f \
            -exec grep \
            -iFx "${_file}/" {} \;
        )
        if [ "${file_found}" == "" ]; then
          echo "${_file}" >> "${query_name}"
        fi
        # In case git is tracking the file already. It removes it as a fallback.
        if [ "${query_name}" == ".gitignore" ]; then
          if [[ "${_file}" != \#* ]]; then
            # NOTE:
            #   - Since repository looper does not have scope to region_name and cluster_name
            #     variabls, the work around is to use find cmd to find the names directory
            #     `region_name/cluster_name`
            file_path=$(find . -name 'charts' | yq '. | split("/") | .[1] + "/" + .[2]')
            if git ls-files --error-unmatch "./${file_path}/${_file}" &> /dev/null; then
              git rm -q -r --cached "./${file_path}/${_file}"
            fi
          fi
        fi
      done
      # Git
      utilGitter "${args_2[@]}"
    else
      logger "ERROR" "'${dependency_name}/${chart_name}' invalid query name '${query_name}'." "${func_name}"
    fi
  fi
}

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
_utilGenerateRegex () {
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
