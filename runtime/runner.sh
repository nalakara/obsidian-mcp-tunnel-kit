#!/bin/bash
set -euo pipefail

BASE="${OBSIDIAN_MCP_BASE:-$HOME/.local/share/obsidian-mcp}"
NODE_BIN="${NODE_BIN:-/usr/local/bin/node}"
CONFIG="${OBSIDIAN_MCP_CONFIG:-$HOME/.config/tunnel-client/obsidian-autostart.yaml}"
OPENAI_SERVICE="Obsidian MCP OpenAI Runtime Key"
OBSIDIAN_SERVICE="Obsidian MCP Obsidian API Key"
ACCOUNT="$(whoami)"

OPENAI_KEY="$(security find-generic-password -a "$ACCOUNT" -s "$OPENAI_SERVICE" -w 2>/dev/null || true)"
OBSIDIAN_KEY="$(security find-generic-password -a "$ACCOUNT" -s "$OBSIDIAN_SERVICE" -w 2>/dev/null || true)"

[[ -n "$OPENAI_KEY" ]] || { echo "FATAL: OpenAI Runtime API Key tidak ditemukan di Keychain."; exit 10; }
[[ -n "$OBSIDIAN_KEY" ]] || { echo "FATAL: Obsidian API Key tidak ditemukan di Keychain."; exit 11; }
[[ -x "$NODE_BIN" ]] || { echo "FATAL: Node tidak ditemukan: $NODE_BIN"; exit 12; }
[[ -x "$BASE/tunnel-client" ]] || { echo "FATAL: tunnel-client tidak ditemukan: $BASE/tunnel-client"; exit 13; }
[[ -x "$BASE/cloudflared" ]] || { echo "FATAL: cloudflared tidak ditemukan: $BASE/cloudflared"; exit 14; }
[[ -f "$BASE/adapter.js" ]] || { echo "FATAL: adapter.js tidak ditemukan: $BASE/adapter.js"; exit 15; }
[[ -f "$BASE/obsidian-local-rest-api.crt" ]] || { echo "FATAL: certificate tidak ditemukan: $BASE/obsidian-local-rest-api.crt"; exit 16; }
[[ -f "$CONFIG" ]] || { echo "FATAL: tunnel config tidak ditemukan: $CONFIG"; exit 17; }

export CONTROL_PLANE_API_KEY="$OPENAI_KEY"
export OBSIDIAN_API_KEY="$OBSIDIAN_KEY"
export OBSIDIAN_CA_BUNDLE="$BASE/obsidian-local-rest-api.crt"
export MCP_AUTHORIZATION="Bearer $OBSIDIAN_KEY"

cleanup() {
  kill "${ADAPTER_PID:-}" "${TUNNEL_PID:-}" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

"$NODE_BIN" "$BASE/adapter.js" >> "$HOME/Library/Logs/obsidian-mcp-adapter.log" 2>&1 &
ADAPTER_PID=$!

for _ in {1..50}; do
  if curl -fsS "http://127.0.0.1:27125/" >/dev/null 2>&1; then break; fi
  if ! kill -0 "$ADAPTER_PID" 2>/dev/null; then
    echo "FATAL: local adapter gagal start."; exit 20
  fi
  sleep 0.1
done

kill -0 "$ADAPTER_PID" 2>/dev/null || { echo "FATAL: local adapter gagal start."; exit 20; }

"$BASE/tunnel-client" run --config "$CONFIG" >> "$HOME/Library/Logs/obsidian-mcp-tunnel.log" 2>&1 &
TUNNEL_PID=$!
wait "$TUNNEL_PID"
