#!/usr/bin/env zsh

# Ensure uv is installed
if ! command -v uv &>/dev/null; then
  echo "❌ uv is not installed. Please install uv before running this script."
  exit 1
fi

echo "🔍 Retrieving installed Python versions..."
# Get list of installed Python versions
installed_versions=($(uv python list --only-installed | awk '{print $1}'))

if [[ ${#installed_versions[@]} -eq 0 ]]; then
  echo "⚠️ No uv-managed Python versions found."
  exit 0
fi

echo "✅ Found ${#installed_versions[@]} installed Python version(s)."

# Function to extract major.minor from a version string
get_minor_version() {
  echo "$1" | cut -d. -f1,2
}

# Function to get the latest available patch version for a given minor version
get_latest_patch() {
  local minor="$1"
  uv python list --all-versions | awk -v minor="$minor" '
    $1 ~ "^"minor"\\." {
      print $1
    }
  ' | sort -V | tail -n1
}

# Iterate over installed versions
for version in "${installed_versions[@]}"; do
  minor_version=$(get_minor_version "$version")
  latest_patch=$(get_latest_patch "$minor_version")

  if [[ -z "$latest_patch" ]]; then
    echo "⚠️ Could not determine the latest patch version for Python $minor_version."
    continue
  fi

  if [[ "$version" == "$latest_patch" ]]; then
    echo "✅ Python $version is up to date."
  else
    echo "⬆️ Updating Python $minor_version to latest patch $latest_patch..."
    uv python install "$minor_version" --reinstall
  fi
done
