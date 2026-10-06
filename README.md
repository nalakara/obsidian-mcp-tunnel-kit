# Obsidian MCP Tunnel Kit

Version 0.1.1

A small macOS runtime bundle for the verified Obsidian → Local REST API → MCP tunnel setup.

This kit packages the local runtime pieces. It does not install Obsidian, modify the vault, or store credentials in the repository.

## Runtime model

```text
launchd
  ↓
runner.sh
  ├── adapter.js → Obsidian Local REST API :27124
  └── tunnel-client → OpenAI control plane
```

The adapter listens on `127.0.0.1:27125` and forwards MCP traffic to Obsidian's HTTPS Local REST API while injecting the Obsidian API key and validating the bundled CA certificate.

## Credentials

Secrets are not committed to the repository.

The runtime retrieves these Keychain items at startup:

- `Obsidian MCP OpenAI Runtime Key`
- `Obsidian MCP Obsidian API Key`

The actual `obsidian-autostart.yaml` is machine-specific user configuration and is never copied from the source machine into this repository. The example config contains placeholders only. The working tunnel-client configuration may still contain its required API-key fields; populate those with real values only on the target machine.

## Bundle contents

The runtime payload is captured from a working machine with `bin/capture-runtime.sh`:

- `tunnel-client`
- `cloudflared`
- `obsidian-local-rest-api.crt`
- `adapter.js`
- `runner.sh`

This avoids guessing where the working binaries came from.

## Install

1. Capture the runtime on the working Mac:

   `bin/capture-runtime.sh`

2. Run:

   `bin/install.sh`

3. Ensure `~/.config/tunnel-client/obsidian-autostart.yaml` exists and contains the user's valid tunnel configuration.

4. Run:

   `bin/doctor.sh`

The installer does not overwrite an existing tunnel config.

## Uninstall

`bin/uninstall.sh` removes only the package-owned runtime and its LaunchAgent. It preserves the tunnel config, Keychain credentials, Obsidian, and vault.
