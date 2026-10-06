#!/bin/bash
set -u

BASE="${OBSIDIAN_MCP_BASE:-$HOME/.local/share/obsidian-mcp}"
CONFIG="${OBSIDIAN_MCP_CONFIG:-$HOME/.config/tunnel-client/obsidian-autostart.yaml}"
PLIST="$HOME/Library/LaunchAgents/com.nalakara.obsidian-mcp.plist"
NODE_BIN="${NODE_BIN:-/usr/local/bin/node}"
PASS=0; FAIL=0
ok(){ echo "[✓] $1"; PASS=$((PASS+1)); }
bad(){ echo "[✗] $1"; FAIL=$((FAIL+1)); }

[[ "$(uname -s)" == "Darwin" ]] && ok "macOS" || bad "macOS"
[[ -d /Applications/Obsidian.app ]] && ok "Obsidian installed" || bad "Obsidian installed"
[[ -x "$NODE_BIN" ]] && ok "Node available: $($NODE_BIN --version 2>/dev/null)" || bad "Node: $NODE_BIN"
[[ -x "$BASE/tunnel-client" ]] && ok "tunnel-client present" || bad "tunnel-client present"
[[ -x "$BASE/cloudflared" ]] && ok "cloudflared present" || bad "cloudflared present"
[[ -x "$BASE/runner.sh" ]] && ok "runner.sh present" || bad "runner.sh present"
[[ -f "$BASE/adapter.js" ]] && ok "adapter.js present" || bad "adapter.js present"
[[ -f "$BASE/obsidian-local-rest-api.crt" ]] && ok "REST API certificate present" || bad "REST API certificate present"
[[ -f "$CONFIG" ]] && ok "autostart config present" || bad "autostart config present"
[[ -f "$PLIST" ]] && ok "LaunchAgent plist present" || bad "LaunchAgent plist present"
security find-generic-password -a "$(whoami)" -s "Obsidian MCP OpenAI Runtime Key" >/dev/null 2>&1 && ok "OpenAI Runtime Key in Keychain" || bad "OpenAI Runtime Key in Keychain"
security find-generic-password -a "$(whoami)" -s "Obsidian MCP Obsidian API Key" >/dev/null 2>&1 && ok "Obsidian API Key in Keychain" || bad "Obsidian API Key in Keychain"
launchctl print "gui/$(id -u)/com.nalakara.obsidian-mcp" >/dev/null 2>&1 && ok "LaunchAgent loaded" || bad "LaunchAgent loaded"
curl -fsS --max-time 2 http://127.0.0.1:27125/ >/dev/null 2>&1 && ok "adapter responding on :27125" || bad "adapter responding on :27125"
pgrep -f "$BASE/tunnel-client run" >/dev/null 2>&1 && ok "tunnel process running" || bad "tunnel process running"

if [[ "$FAIL" -eq 0 ]]; then
  echo; echo "OBSIDIAN MCP TUNNEL: READY"
else
  echo; echo "OBSIDIAN MCP TUNNEL: NOT READY ($FAIL checks failed, $PASS passed)"
fi
exit "$FAIL"
