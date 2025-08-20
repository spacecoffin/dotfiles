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

# Build associative array of unique minor versions and their latest installed patch
declare -A minor_to_latest_installed
for version in "${installed_versions[@]}"; do
  minor_version=$(get_minor_version "$version")

  # If this minor version isn't in our array yet, or this version is newer than what we have
  if [[ -z "${minor_to_latest_installed[$minor_version]}" ]] || \
     [[ "$(printf '%s\n' "$version" "${minor_to_latest_installed[$minor_version]}" | sort -V | tail -n1)" == "$version" ]]; then
    minor_to_latest_installed[$minor_version]="$version"
  fi
done

echo "📋 Found ${#minor_to_latest_installed[@]} unique minor version(s): ${(k)minor_to_latest_installed[@]}"

# Iterate over unique minor versions
for minor_version in "${(@k)minor_to_latest_installed}"; do
  installed_latest="${minor_to_latest_installed[$minor_version]}"
  available_latest=$(get_latest_patch "$minor_version")

  if [[ -z "$available_latest" ]]; then
    echo "⚠️ Could not determine the latest patch version for Python $minor_version."
    continue
  fi

  if [[ "$installed_latest" == "$available_latest" ]]; then
    echo "✅ Python $minor_version is up to date ($installed_latest)."
  else
    echo "⬆️ Updating Python $minor_version from $installed_latest to latest patch $available_latest..."
    uv python install "$minor_version" --reinstall
  fi
done
