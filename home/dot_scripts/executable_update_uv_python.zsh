#!/usr/bin/env zsh

# Ensure uv is installed
if ! command -v uv &>/dev/null; then
  echo "❌ uv is not installed. Please install uv before running this script."
  exit 1
fi

echo "🔍 Retrieving installed Python versions..."
# Get list of installed Python versions with freethreaded designation
installed_versions=($(uv python list --only-installed | awk '{
  if ($1 ~ /\+freethreaded/) {
    # Extract version and add "t" suffix for freethreaded
    gsub(/cpython-/, "", $1)
    gsub(/\+freethreaded.*/, "t", $1)
  } else {
    # Extract standard version
    gsub(/cpython-/, "", $1)
    gsub(/-.*/, "", $1)
  }
  print $1
}'))

if [[ ${#installed_versions[@]} -eq 0 ]]; then
  echo "⚠️ No uv-managed Python versions found."
  exit 0
fi

echo "✅ Found ${#installed_versions[@]} installed Python version(s)."

# Function to extract major.minor from a version string, preserving freethreaded designation
get_minor_version() {
  local version="$1"
  if [[ "$version" == *"t" ]]; then
    # Freethreaded version - remove 't' suffix, extract major.minor, add 't' back
    echo "${version%t}" | cut -d. -f1,2 | sed 's/$/t/'
  else
    # Standard version
    echo "$version" | cut -d. -f1,2
  fi
}

# Function to get the latest available patch version for a given minor version
get_latest_patch() {
  local minor="$1"
  local is_freethreaded=false
  
  if [[ "$minor" == *"t" ]]; then
    is_freethreaded=true
    # Remove 't' suffix for pattern matching
    minor="${minor%t}"
  fi
  
  if [[ "$is_freethreaded" == "true" ]]; then
    # Get freethreaded versions
    uv python list --all-versions | awk -v minor="$minor" '
      $1 ~ "cpython-"minor"\\..*\\+freethreaded" {
        gsub(/cpython-/, "", $1)
        gsub(/\+freethreaded.*/, "t", $1)
        print $1
      }
    ' | sort -V | tail -n1
  else
    # Get standard versions (exclude freethreaded)
    uv python list --all-versions | awk -v minor="$minor" '
      $1 ~ "cpython-"minor"\\." && $1 !~ "\\+freethreaded" {
        gsub(/cpython-/, "", $1)
        gsub(/-.*/, "", $1)
        print $1
      }
    ' | sort -V | tail -n1
  fi
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
    # Determine the correct installation target
    if [[ "$minor_version" == *"t" ]]; then
      # Install freethreaded version
      local install_target="${minor_version%t}+freethreaded"
    else
      # Install standard version
      local install_target="$minor_version"
    fi
    uv python install "$install_target" --reinstall
  fi
done
