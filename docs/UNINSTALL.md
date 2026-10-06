# Uninstallation

Run:

```bash
bin/uninstall.sh
```

It removes only:

- `~/.local/share/obsidian-mcp`
- `~/Library/LaunchAgents/com.nalakara.obsidian-mcp.plist`

It does not remove:

- Obsidian
- the vault
- Keychain credentials
- `~/.config/tunnel-client`
- other tunnel-client configuration
