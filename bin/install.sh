#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE="${OBSIDIAN_MCP_BASE:-$HOME/.local/share/obsidian-mcp}"
CONFIG_DIR="$HOME/.config/tunnel-client"
CONFIG="$CONFIG_DIR/obsidian-autostart.yaml"
PLIST="$HOME/Library/LaunchAgents/com.nalakara.obsidian-mcp.plist"

for f in runner.sh adapter.js tunnel-client cloudflared obsidian-local-rest-api.crt; do
  [[ -e "$ROOT/runtime/$f" ]] || { echo "FATAL: runtime/$f missing. Run bin/capture-runtime.sh first."; exit 1; }
done
[[ -x "${NODE_BIN:-/usr/local/bin/node}" ]] || { echo "FATAL: Node not found at ${NODE_BIN:-/usr/local/bin/node}"; exit 2; }

mkdir -p "$BASE" "$CONFIG_DIR" "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
cp "$ROOT/runtime/runner.sh" "$BASE/runner.sh"
cp "$ROOT/runtime/adapter.js" "$BASE/adapter.js"
cp "$ROOT/runtime/tunnel-client" "$BASE/tunnel-client"
cp "$ROOT/runtime/cloudflared" "$BASE/cloudflared"
cp "$ROOT/runtime/obsidian-local-rest-api.crt" "$BASE/obsidian-local-rest-api.crt"
chmod 700 "$BASE/runner.sh" "$BASE/tunnel-client"
chmod 755 "$BASE/cloudflared"
chmod 644 "$BASE/adapter.js" "$BASE/obsidian-local-rest-api.crt"

if [[ ! -f "$CONFIG" ]]; then
  cp "$ROOT/config/obsidian-autostart.yaml.example" "$CONFIG"
  chmod 600 "$CONFIG"
  echo "Created config template at $CONFIG"
else
  echo "Existing tunnel config preserved: $CONFIG"
fi

sed -e "s#__INSTALL_DIR__#$BASE#g" -e "s#__HOME__#$HOME#g" \
  "$ROOT/launchd/com.nalakara.obsidian-mcp.plist" > "$PLIST"
chmod 644 "$PLIST"

launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl kickstart -k "gui/$(id -u)/com.nalakara.obsidian-mcp" || true

echo "Installed and loaded com.nalakara.obsidian-mcp"
