#!/bin/bash

# TODO:
# - findout how to check if a brew tap is already install.
# - add aws localstack in dependencies.json
#   {
#     "pip": {
#       "awslocal": "https://docs.localstack.cloud/user-guide/integrations/aws-cli/#localstack-aws-cli-awslocal",
#       "terraform-local": "trlocal"
#     }
#   }
#

# NOTE:
# - If it's a new computer, most likely the machine does not
#   have `brew` and/or `git` installed. Therefore you must do the following:
#     1) create a folder.
#     2) login into github and go to repo `boilerplate`
#     3) Copy the files `dependencies.json` and `main.sh` from github account.
#     4) On the terminal do "bash main.sh"
#
#   brew must be install first before even cloning a repo
#
# - If your computer already have `brew` and `git` install
#     1) clone this repo `boilerplay`
#
echo "$SHELL"

hasMacChip() {
  is_mac_chip=false
  if [[ $(uname -m) == 'arm64' ]]; then
    is_mac_chip=true
  fi
  echo "${is_mac_chip=false}"
}

# Install a brew package
# ARGS:
# - $1 - package_name
# - $2 - _type
# - $3 - _command
brewInstallPackage() {
  package_name=$1
  _type=$2
  _command=$3
  echo "${package_name}"
  success_message="Installing "${_type}" ${package_name}..."
  error_message="${package_name}'s ${_type} does not exist..."
  # tap
  if [[ "$_type" == "tap" ]]; then
    echo "${success_message}"
    # echo "$(brew --repository)/Library/Taps/${package_name}"
    # /opt/homebrew/Library/Taps/knative
    # brew tap-info "knative/client" --json
    brew install "${package_name}"

  # fomulae and cask
  else
    flag="--${_type}"
    if brew ls --versions "${flag}" "${package_name}" &>/dev/null; then
      echo "${package_name} is already installed..."
    else
      if brew search "${flag}" "${package_name}" &>/dev/null; then
        echo "${message}"
        brew install "${flag}" "${package_name}"
      else
        echo "${error_message}"
      fi
    fi
  fi
  # IMPORTANT:
  # https://www.rust-lang.org/tools/install
  # For rustup, to install rust compiler and package-manager. Run these commands:
  #$ rustup-init
  #$ source "$HOME/.cargo/env"
}

installOhMyZsh() {
  if [ -d ~/.oh-my-zsh ]; then
    echo "oh-my-zsh is already installed..."
  else
    echo "oh-my-zsh is not installed"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    chsh -s $(which zsh)
  fi
}

# Installs brew
brewInstall() {
  which -s brew
  if [[ $? != 0 ]] ; then
    echo "Brew does not exist..."
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # IMPORTANT:
    #   - These 2 lines may not work, so it must be manually executre in your teminal.
    # Run these two commands in your terminal to add Homebrew to your PATH:
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/juan.ordaz/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    # brew update
    echo "Brew already exist..."
  fi
  # must be hard-coded because at this point we don't have access to jq when
  # is a new computer.
  brewInstallPackage "jq" "formulae"

  # Return array: (<[package_name]>.<[type]> <[package_name]>.<[type]>)
  brew_packages=($(jq -r '.tools[] | select(.name=="Homebrew").libraries[] | select(.package_name != "example") | (.package_name + "." + .type + "." + .command)' dependencies.json))
  # echo "${brew_packages[@]}"
  # ---------------------------------------------------------------------------
  # NOTE: Do remove the below code. It's helpful to remember how to create different
  #       arrays using jq
  # brew_packages=$(jq -r '.tools[] | select(.name=="Homebrew").libraries[] | select(.package_name != "example")' dependencies.json)
  # brew_formulae_packages=($(jq -r  'select(.type == "formulae").package_name' <<< "${brew_packages[@]}"))
  # brew_cask_packages=($(jq -r  'select(.type == "cask").package_name' <<< "${brew_packages[@]}"))
  # brew_tap_packages=($(jq -r  'select(.type == "tap").package_name' <<< "${brew_packages[@]}"))
  # echo "${brew_formulae_packages[@]}"
  # ---------------------------------------------------------------------------

  has_mac_chip=$(hasMacChip)

  for package_info in "${brew_packages[@]}"; do
    # echo "${package_info} blahhh"
    # Create an array...
    package_info_arr=($(echo $package_info | tr "." " "))
    package_name="$(echo ${package_info_arr[0]})"
    _type="${package_info_arr[1]}"
    _command="${package_info_arr[2]}"
    if [ "${has_mac_chip}" == "true" ] && [ "${package_name}" == "hyperkit" ]; then
      echo "${package_name} is not supported in mac chips yet. Use qemu or docker driver."
      continue
    fi
    echo "${package_name} ${_type}---------------"
    brewInstallPackage "${package_name}" "${_type}" "${_command}"
  done
}

main() {
  brewInstall
  installOhMyZsh
}

main
