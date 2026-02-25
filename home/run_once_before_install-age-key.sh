#!/bin/bash
set -e

KEY_PATH="$HOME/.config/chezmoi/key.txt"

if [ -f "$KEY_PATH" ]; then
  exit 0
fi

echo "chezmoi: age key not found, fetching from 1Password..."
mkdir -p "$(dirname "$KEY_PATH")"
op document get "chezmoi age key" --output "$KEY_PATH"
chmod 600 "$KEY_PATH"
echo "chezmoi: age key restored successfully"
