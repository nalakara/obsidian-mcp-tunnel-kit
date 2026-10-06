#!/bin/bash
set -euo pipefail

SRC="${OBSIDIAN_MCP_SOURCE:-$HOME/.local/share/obsidian-mcp}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DST="$ROOT/runtime"

for f in tunnel-client cloudflared obsidian-local-rest-api.crt; do
  [[ -f "$SRC/$f" ]] || { echo "FATAL: missing $SRC/$f"; exit 1; }
done

cp "$SRC/tunnel-client" "$DST/tunnel-client"
cp "$SRC/cloudflared" "$DST/cloudflared"
cp "$SRC/obsidian-local-rest-api.crt" "$DST/obsidian-local-rest-api.crt"
chmod 700 "$DST/tunnel-client"
chmod 755 "$DST/cloudflared"
chmod 644 "$DST/obsidian-local-rest-api.crt"

echo "Runtime captured from $SRC"
ls -lh "$DST/tunnel-client" "$DST/cloudflared" "$DST/obsidian-local-rest-api.crt"
