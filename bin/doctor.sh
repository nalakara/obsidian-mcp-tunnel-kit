#!/bin/bash
set -u

echo "== Obsidian MCP Tunnel Doctor v0.1.0 =="
echo

ok=0
warn=0
fail=0

check() {
  local label="$1"
  local cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    printf "✓ %s\n" "$label"
    ok=$((ok+1))
  else
    printf "✗ %s\n" "$label"
    fail=$((fail+1))
  fi
}

if [[ "$(uname -s)" == "Darwin" ]]; then
  printf "✓ macOS detected\n"
  ok=$((ok+1))
else
  printf "⚠ This kit was designed for macOS\n"
  warn=$((warn+1))
fi

if [[ -d "/Applications/Obsidian.app" ]]; then
  printf "✓ Obsidian.app found\n"
  ok=$((ok+1))
else
  printf "✗ Obsidian.app not found in /Applications\n"
  fail=$((fail+1))
fi

if command -v tunnel-client >/dev/null 2>&1; then
  printf "✓ tunnel-client found: %s\n" "$(command -v tunnel-client)"
  ok=$((ok+1))
else
  printf "⚠ tunnel-client not found in PATH\n"
  warn=$((warn+1))
fi

CONFIG="$HOME/.config/tunnel-client/obsidian.yaml"
if [[ -f "$CONFIG" ]]; then
  printf "✓ Obsidian tunnel profile found: %s\n" "$CONFIG"
  ok=$((ok+1))
else
  printf "⚠ Obsidian tunnel profile not found: %s\n" "$CONFIG"
  warn=$((warn+1))
fi

CERT="$HOME/.config/tunnel-client/obsidian-local-rest-api.crt"
if [[ -f "$CERT" ]]; then
  printf "✓ Obsidian REST API certificate found\n"
  ok=$((ok+1))
else
  printf "⚠ Obsidian REST API certificate not found\n"
  warn=$((warn+1))
fi

echo
echo "Summary: $ok OK, $warn warnings, $fail failures"

if [[ "$fail" -eq 0 ]]; then
  echo "Status: local prerequisites look good."
  exit 0
else
  echo "Status: setup needs attention."
  exit 1
fi
