#!/bin/bash
set -euo pipefail

KIT_DIR="${HOME}/.local/share/obsidian-mcp-tunnel-kit"

echo "== Removing Obsidian MCP Tunnel Kit =="

if [[ -d "$KIT_DIR" ]]; then
  rm -rf "$KIT_DIR"
  echo "Removed: $KIT_DIR"
else
  echo "Toolkit directory not found."
fi

cat <<EOF

Not removed:
  ~/.config/tunnel-client/
  tunnel-client binary
  Obsidian
  Obsidian vault
  Local REST API plugin

Those are intentionally left untouched because they may be shared with
other workflows.

If you want to remove the entire tunnel-client installation, do that
separately after verifying it is no longer needed.
EOF
