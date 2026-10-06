#!/bin/bash
set -euo pipefail

KIT_DIR="${HOME}/.local/share/obsidian-mcp-tunnel-kit"
CONFIG_DIR="${HOME}/.config/tunnel-client"

echo "== Installing Obsidian MCP Tunnel Kit v0.1.0 =="

mkdir -p "$KIT_DIR" "$CONFIG_DIR"
cp "$(dirname "$0")/doctor.sh" "$KIT_DIR/doctor.sh"
chmod +x "$KIT_DIR/doctor.sh"

if [[ ! -f "$CONFIG_DIR/obsidian.yaml" ]]; then
  cp "$(dirname "$0")/../config/obsidian.yaml.example"      "$CONFIG_DIR/obsidian.yaml.example"
  echo "Created configuration template:"
  echo "  $CONFIG_DIR/obsidian.yaml.example"
else
  echo "Existing tunnel configuration detected; leaving it untouched."
fi

cat <<EOF

Installation complete.

Next:
  1. Verify your existing tunnel-client installation.
  2. Run:
       $KIT_DIR/doctor.sh

This installer does not create credentials or overwrite an existing profile.
EOF
