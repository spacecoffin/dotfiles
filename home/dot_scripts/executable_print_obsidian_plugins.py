#!/usr/bin/env python3

import argparse
import json
import re
import sys
from pathlib import Path


DEFAULT_VAULT_PATH = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/RRRR/"
MANIFEST_KEY_NAME = "name"
MANIFEST_KEY_ID = "id"
INVALID_CHARS_PATTERN = re.compile(r'[/\\<>"|?*]')


def get_value_from_json(file_path: Path, key: str) -> str | None:
    """Extract a value from a JSON file."""
    try:
        with file_path.open() as json_file:
            data = json.load(json_file)
        return data.get(key)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Warning: Could not read {file_path}: {e}", file=sys.stderr)
        return None


def main() -> None:
    """List enabled and disabled Obsidian plugins from a vault."""
    parser = argparse.ArgumentParser(
        description="List enabled and disabled Obsidian plugins from a vault."
    )
    parser.add_argument(
        "--vault-path",
        type=Path,
        default=Path(DEFAULT_VAULT_PATH).expanduser(),
        help=f"Path to Obsidian vault (default: {DEFAULT_VAULT_PATH})",
    )
    args = parser.parse_args()

    vault_path = args.vault_path.expanduser()

    if not vault_path.exists():
        print(f"Error: Vault path does not exist: {vault_path}", file=sys.stderr)
        sys.exit(1)

    obsidian_settings_path = vault_path / ".obsidian"
    community_plugin_folder_path = obsidian_settings_path / "plugins"
    core_plugins_file_path = obsidian_settings_path / "core-plugins-migration.json"
    community_plugins_file_path = obsidian_settings_path / "community-plugins.json"

    if not obsidian_settings_path.exists():
        print(
            f"Error: .obsidian folder not found in vault: {vault_path}",
            file=sys.stderr,
        )
        sys.exit(1)

    # read in list of core plugins and activation state
    try:
        with core_plugins_file_path.open() as f:
            core_plugins_dict = json.load(f)
    except FileNotFoundError:
        print(
            f"Warning: {core_plugins_file_path.name} not found, skipping core plugins",
            file=sys.stderr,
        )
        core_plugins_dict = {}

    # read in list of enabled community plugins
    try:
        with community_plugins_file_path.open() as f:
            community_plugins_list = json.load(f)
    except FileNotFoundError:
        print(
            f"Warning: {community_plugins_file_path.name} not found,"
            " skipping community plugins",
            file=sys.stderr,
        )
        community_plugins_list = []

    # get plugin folders and extract metadata
    plugin_folders = (
        [
            folder.name
            for folder in community_plugin_folder_path.iterdir()
            if folder.is_dir()
        ]
        if community_plugin_folder_path.exists()
        else []
    )

    community_plugin_name_list = [
        (
            get_value_from_json(
                community_plugin_folder_path / plugin / "manifest.json",
                MANIFEST_KEY_NAME,
            ),
            get_value_from_json(
                community_plugin_folder_path / plugin / "manifest.json",
                MANIFEST_KEY_ID,
            ),
        )
        for plugin in plugin_folders
    ]

    # split into enabled and not enabled lists.
    # 	Do both core and community plugins,
    # 	add (core) or (community) to end for tracking in name
    enabled_plugins = []
    disabled_plugins = []

    for plugin_key, is_enabled in core_plugins_dict.items():
        plugin_label = f"{plugin_key} (Core)"
        if is_enabled:
            enabled_plugins.append(plugin_label)
        else:
            disabled_plugins.append(plugin_label)

    for plugin_name, plugin_id in community_plugin_name_list:
        if plugin_name is None or plugin_id is None:
            continue
        plugin_label = f"{plugin_name} (Community)"
        if plugin_id in community_plugins_list:
            enabled_plugins.append(plugin_label)
        else:
            disabled_plugins.append(plugin_label)

    # output list of enabled plugins
    print("Enabled Plugins\n")
    for name in sorted(enabled_plugins):
        sanitized_name = INVALID_CHARS_PATTERN.sub("-", name)
        print(f"- {sanitized_name}")

    # output list of disabled plugins
    print("\nDisabled Plugins\n")
    for name in sorted(disabled_plugins):
        sanitized_name = INVALID_CHARS_PATTERN.sub("-", name)
        print(f"- {sanitized_name}")


if __name__ == "__main__":
    main()
