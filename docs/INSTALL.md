# Installation

This kit is designed to be captured from a known-good working setup and then installed elsewhere on the same architecture.

## 1. Capture runtime

On the working Mac:

```bash
bin/capture-runtime.sh
```

This copies the verified `tunnel-client`, `cloudflared`, and Local REST API certificate into `runtime/`.

Do not copy `~/.config/tunnel-client/obsidian-autostart.yaml` into the package; it contains machine/tunnel credentials and identity.

## 2. Install

```bash
bin/install.sh
```

The installer copies the runtime, creates the LaunchAgent, preserves an existing tunnel config, and loads the service.

## 3. Configure

If no config exists, edit:

`~/.config/tunnel-client/obsidian-autostart.yaml`

using the example as a template.

Credentials remain in macOS Keychain.

## 4. Verify

```bash
bin/doctor.sh
```
