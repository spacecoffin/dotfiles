#!/bin/sh

# Exit on error
set -e

# Ensure ngc is installed
if ! command -v ngc >/dev/null 2>&1; then
  echo "❌ NGC CLI is not installed: https://org.ngc.nvidia.com/setup/installers/cli"
  exit 1
fi

# Ensure dasel is installed
if ! command -v dasel >/dev/null 2>&1; then
  echo "❌ 'dasel' is required but not found. Install via: brew install dasel"
  exit 1
fi

# Get current version from JSON
current_version=$(ngc --version | sed 's/NGC CLI //')

# Get latest version from version list
latest_version=$(ngc version info --format_type json | awk 'BEGIN{found=0} /^\s*{/ {found=1} found' | dasel -i json 'versionId' | tr -d '"')

# Compare and decide
if [ "$current_version" = "$latest_version" ]; then
  echo "✅ NGC CLI is up to date (version $current_version)"
else
  echo "⬆️ Updating NGC CLI from $current_version to $latest_version..."
  ngc version upgrade
fi
