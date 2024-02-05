#!/bin/bash

#
# TODO:
#   - consider adding charts to s3?
#   - fix log_msg for git. currenlty is using the same log msg.
#   - make sure the version of tgz file is not longer use in other clusters.
#     before deleting the tgz file.
#   - `diff-current-to-latest-version-manifests and`
#     `diff-current-to-per-newer-version-manifests`
#
# NOTE:
#   - main.sh hc-create-chart must be executed first to create the ./versions
#     folder.
#
# DESCRIPTION:
#   - Creates a file for each version in `.releases` from `clusters.yaml`
#     in ./versions/${sub_folder}/xxx.<[ext]>
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
funcHelmChartConfigsUpdateVersionsFolder () {
  local -r func_name="${FUNCNAME[0]}"
  local -r args=("$@")
  local -r dependency_name="${args[0]}"
  local -r chart_name="${args[1]}"
  local -r region_name="${args[2]}"
  local -r cluster_name="${args[3]}"
  local -r dependency_obj="${args[4]}"
  # local -r initial_chart_name="${args[5]}"

  if [ -f "./Chart.yaml" ]; then
    # Resets ./versions folder to prevent writing code to handle duplicates.
    rm -rf ./versions
    utilCreateHelmChartVersionsFolder
    local current_version=""
    current_version=$( \
      # shellcheck disable=SC2016
      _dependency_obj="${dependency_obj}" \
      yq \
        -n \
        '
          env(_dependency_obj) as $_dependency_obj
          | $_dependency_obj
          | .version
        '
    )
    local -a releases=("${current_version}")
    # Get region names
    while IFS= read -r value; do
      releases+=("${value}")
    done < <( \
      # shellcheck disable=SC2016
      _dependency_obj="${dependency_obj}" \
      yq \
        -n \
        '
          env(_dependency_obj) as $_dependency_obj
          | $_dependency_obj
          | .releases[]
        ' \
    )
    # NOTE:
    #   - tgzs folder must be executed first, because all the other folders
    #     depend on this 'xxx.tgz' file to exist first.
    local -a sub_folders=()
    while IFS= read -r sub_folder; do
      if [ "${sub_folder}" == "tgzs" ] || [ "${sub_folder}" == "values" ]; then
        continue
      fi
      sub_folders+=("${sub_folder}")
    done < <( \
      ls "./versions"
    )

    # rm -rf "./versions/manifests"

    sub_folders=("tgzs" "values" "${sub_folders[@]}")

    # Get names of folders
    for sub_folder in "${sub_folders[@]}"; do
      if [ "$sub_folder" == "" ]; then
        continue
      fi
      local -a sub_folder_files_versions=()
      while IFS= read -r file_name; do
        local file_version=""
        file_version=$( \
          # NOTE:
          #   - it skips the _test file.
          # shellcheck disable=SC2016
          _file_name="${file_name}" \
          yq \
            -n \
            '
              env(_file_name) as $_file_name
              | $_file_name
              | . | split(".")
              | (. | length) as $i
              | del(.[$i - 1])
              | . | join(".")
              | with(select(. == "_test");
                  . = false
                )
              | .
            '
        )
        if [ "${file_version}" != "false" ]; then
          sub_folder_files_versions+=("${file_version}")
        fi
      done < <( \
        ls ./versions/"${sub_folder}"
      )

      local -a versions_to_remove=()

      for file_version in "${sub_folder_files_versions[@]}"; do
        is_version_found=$( \
          #  NOTE:
          #   - concatinate $_chart_name and release, because
          #     helm pulls the chart as follows: <[chart_name]>-<[release]>.tgz
          # shellcheck disable=SC2016
          _file_version="${file_version}" \
          _releases="${releases[*]}" \
          _chart_name="${chart_name}" \
          yq \
            -n \
            '
              (env(_releases) | split(" ")) as $_releases
              | env(_file_version) as $_file_version
              | env(_chart_name) as $_chart_name
              | [] as $new_arr
              | $_releases[]
              | $_chart_name + "-" + .
              | select(. == $_file_version)
              | . == $_file_version
            '
        )
        if [ "${is_version_found}" == "false" ]; then
          versions_to_remove+=("${file_version}")
        fi
      done

      # TODO: add rm command. or mabye on the if-statement above. This will preven duplicate files.
      for version_to_remove in "${versions_to_remove[@]}"; do
        echo "Remove: ${version_to_remove}"
      done

      local last_release="${releases[${#releases[@]}-1]}"

      sleep 1

      for release in "${releases[@]}"; do
        # To be safe... to always have the diff of current version and newer versions.
        # If exist, it will skips.
        if ls ./versions/"${sub_folder}"/"${chart_name}-${release}"* 1> /dev/null 2>&1; then
          continue
        fi
        # diff current version is not needed.
        if [ "${sub_folder}" == "diff-current-to-per-newer-version-values" ] && [ "${current_version}" == "${release}" ]; then
          continue
        fi
        if [ "${sub_folder}" == "diff-current-to-latest-version-values" ] && [ "${release}" != "${last_release}" ]; then
          continue
        fi

        (
          cd ./versions/"${sub_folder}" &&
          local log_msg=""
          case "${sub_folder}" in
            "tgzs")
              log_msg="Pulling ${dependency_name}/${chart_name}/${region_name}/${cluster_name} helm-chart's '${sub_folder}' @ '${release}'."
              logger "INFO" "${log_msg}" "${func_name}"
              helm pull "${dependency_name}/${chart_name}" \
                --version "${release}"
              sleep 1
              ;;
            "values")
              log_msg="Getting ${dependency_name}/${chart_name}/${region_name}/${cluster_name} helm-chart's '${sub_folder}' @ '${release}'."
              logger "INFO" "${log_msg}" "${func_name}"
              helm show values "../tgzs/${chart_name}-${release}.tgz" > "${chart_name}-${release}.yaml"
              sleep 1
              ;;
            # Make sure to sync the diff when updating from .version
            # otherwise it will contain the differances of the old version and release.
            "diff-current-to-per-newer-version-values" | "diff-current-to-latest-version-values")
              log_msg="Getting ${dependency_name}/${chart_name}/${region_name}/${cluster_name} helm-chart's '${sub_folder}' diff from '${current_version}' to '${release}'."
              logger "INFO" "${log_msg}" "${func_name}"
              git \
                diff \
                  --no-index \
                  --unified=0 \
                  "../values/${chart_name}-${current_version}.yaml" "../values/${chart_name}-${release}.yaml" \
                    > "${chart_name}-${release}.yaml"
              sleep 1
              ;;
            *)
              ;;
          esac
        )
      done
    done
    # Do not push per file (inside the loop above). It will mess up with .git
    # history. it will throw an error like: `fatal: unable to read tree cdf6288f99da433f9b56d6d0eadb30e0239a4577`
    # If it does mess it up, do:
    #   - `rm -rf .git/`
    #   - `git init`
    #   - `git remote add <repo>`
    #   - `git checkout -b main`
    #   - `git rebase origin/main`
    #   - `git push --set-upstream orgin main
    local -a args_2=( \
      "${func_name}" \
      "Updated ./versions folder. Executed by '${func_name}'." \
    )
    utilGitter "${args_2[@]}"
  fi
}
