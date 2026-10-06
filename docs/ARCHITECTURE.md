# Architecture

The verified runtime is deliberately small:

```text
macOS launchd
      ↓
 runner.sh
   ┌──┴──────────────┐
   ↓                 ↓
adapter.js       tunnel-client
   ↓                 ↓
Obsidian Local   OpenAI control
REST API :27124     plane
   ↑
   └── :27125 local MCP bridge
```

`runner.sh` reads both runtime credentials from macOS Keychain, starts the adapter, waits for the local bridge, then starts `tunnel-client`.

`adapter.js` terminates local HTTP on `127.0.0.1:27125`, forwards to Obsidian's HTTPS REST API on `127.0.0.1:27124`, injects the Obsidian API authorization header, and validates the supplied CA certificate.

`cloudflared` is bundled because it is part of the verified tunnel runtime payload even though `runner.sh` does not invoke it directly.
