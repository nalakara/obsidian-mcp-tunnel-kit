#!/bin/bash
set -euo pipefail

BASE="${OBSIDIAN_MCP_BASE:-$HOME/.local/share/obsidian-mcp}"
PLIST="$HOME/Library/LaunchAgents/com.nalakara.obsidian-mcp.plist"

launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
rm -f "$PLIST"
rm -rf "$BASE"

echo "Removed package-owned runtime and LaunchAgent."
echo "Preserved: Obsidian, vault, Keychain credentials, ~/.config/tunnel-client, and other external files."
