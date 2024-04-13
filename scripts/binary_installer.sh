#!/usr/bin/env bash

# This script is used to install binaries from remote URLs to a specified directory.
# Usage:
# ./binary_installer.sh <binary_name> <script_mode> <release_url> <install_path> [verify_cmd] [--debug]
#
# Parameters:
#   <binary_name>: Name of the binary to install.
#   <script_mode>: Mode of installation, either "tar" or "binary".
#   <release_url>: URL of the binary release.
#   <install_path>: Directory where the binary will be installed.
#   [verify_cmd]: Optional command to verify the installation.
#   [--debug]: Optional flag to enable debug mode for verbose output.
#
# Note:
#   - If <binary_name> already exists in <install_path>, the installation fails.
#   - Supported values for <script_mode> are "tar" and "binary".
#   - Supported architectures: amd64, arm64, ppc64le, s390x.
#   - For ARM64 architecture, if the binary is not available, it falls back to downloading the amd64 binary.
#   - The script attempts to determine the OS and architecture automatically.
#   - After installation, the script can optionally perform a verification command.
#   - Use the --debug flag to enable debug mode for verbose output.

set -e

# Function to emulate `readlink -f` behavior on macOS
# See: https://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac
function readlink_f() {
  local target_file="$1"
  local phys_dir
  local result

  # Loop until the target_file is not a symbolic link
  while [ -L "$target_file" ]; do
    # Get the physical directory path of the current target file
    phys_dir=$(cd "$(dirname "$target_file")" && pwd -P)
    # Resolve the symbolic link and update target_file with its target
    target_file=$(readlink "$target_file")
    # Extract the base name of the target file
    target_file=$(basename "$target_file")
    # Combine the physical directory path and the base name to get the new target_file
    target_file="$phys_dir/$target_file"
  done

  # Get the final physical directory path of the target file
  phys_dir=$(cd "$(dirname "$target_file")" && pwd -P)
  # Combine the final physical directory path and the base name to get the result
  result="$phys_dir/$(basename "$target_file")"
  # Output the final result
  echo "$result"
}

# Function to echo debug messages
debug_echo() {
  if [ "$debug" = true ]; then
    echo "$@"
  fi
}

# Function to install the binary
install_binary() {
  local binary_name=$1
  local script_mode=$2
  local release_url=$3
  local install_path=$4
  local verify_cmd=$5

  if [ -e "${install_path}${binary_name}" ]; then
    echo "[FAIL] ${install_path}${binary_name} exists. Remove it first."
    exit 1
  fi

  local tmpDir
  tmpDir=$(mktemp -d) || {
    echo "[FAIL] Could not create temp dir."
    exit 1
  }
  trap 'rm -rf "$tmpDir"' EXIT ERR

  pushd "$tmpDir" >&/dev/null || exit 1

  local opsys
  local arch
  opsys=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch=$(uname -m)

  # Supported values of 'arch': amd64, arm64, ppc64le, s390x
  case "$arch" in
  x86_64) arch=amd64 ;;
  arm64 | aarch64) arch=arm64 ;;
  ppc64le) arch=ppc64le ;;
  s390x) arch=s390x ;;
  *) arch=amd64 ;;
  esac

  # Constructing RELEASE_URL with the current architecture
  local RELEASE_URL="${release_url//"{INJECT_ARCH}"/$arch}"
  debug_echo "[DEBUG] Attempting to install $binary_name from $RELEASE_URL to $install_path"

  # Extracting the binary based on script_mode
  local extracted_binary

  if [[ "$script_mode" == "tar" ]]; then
    # Downloading the resource and saving as downloaded_resource
    debug_echo "[DEBUG] Downloading tool using tar mode"
    curl -sL -o downloaded_resource "$RELEASE_URL"
    tar xzf downloaded_resource
    rm -f downloaded_resource
    # Let's find the find the executable with a max depth of 2
    extracted_binary=$(find . -maxdepth 2 -type f -executable -print -quit)
    debug_echo "[DEBUG] Found binary is $extracted_binary"
  elif [[ "$script_mode" == "binary" ]]; then
    # Downloading the resource and saving
    debug_echo "[DEBUG] Downloading tool using binary mode"
    curl -sLO "$RELEASE_URL"
    extracted_binary=$(basename "$RELEASE_URL")
    debug_echo "[DEBUG] Found binary is $extracted_binary"
  elif [[ "$script_mode" == "zip" ]]; then
    # Downloading the resource and saving
    debug_echo "[DEBUG] Downloading tool using zip mode"
    curl -sL -o downloaded_resource "$RELEASE_URL"
    unzip -d op downloaded_resource
    rm -f downloaded_resource
    # Let's find the find the executable with a max depth of 2
    extracted_binary=$(find . -maxdepth 2 -type f -executable -print -quit)
    debug_echo "[DEBUG] Found binary is $extracted_binary"
  fi

  # Installing the binary
  if [[ -n "$extracted_binary" ]]; then
    chmod +x "./$extracted_binary"
    mv "./$extracted_binary" "${install_path}${binary_name}"
    echo "[OK] Installed successfully"
  else
    echo "[FAIL] Failed while installing binary."
    exit 1
  fi

  popd >&/dev/null || exit 1

  # Verifying the installation with verify_cmd if provided
  if [[ "$verify_cmd" ]]; then
    debug_echo "[DEBUG] Attempting to verify installation using command '${install_path}${binary_name} $verify_cmd'"
    if output=$("${install_path}${binary_name}" "$verify_cmd" 2>&1); then
      echo "[OK] Verification command successful"
    else
      echo "[FAIL] Verification command failed: $output"
      exit 1
    fi
  fi
}

# Main
debug=false
binary_name=$1
script_mode=$2
release_url=$3
install_path="$(readlink_f "$4")/"
verify_cmd=$5

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  --debug)
    echo "[DEBUG] Enabling debug mode for verbose output"
    debug=true
    shift
    ;;
  *)
    shift
    ;;
  esac
done

if [ ! -d "$install_path" ]; then
  echo "$install_path does not exist. You need to create it first."
  exit 1
fi

echo "[INFO] Using binary installer in $script_mode mode"
install_binary "$binary_name" "$script_mode" "$release_url" "$install_path" "$verify_cmd"
