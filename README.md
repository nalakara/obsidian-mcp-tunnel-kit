# Obsidian MCP Tunnel Kit v0.1.0

A small, boring toolkit for making the Obsidian MCP Tunnel setup reproducible,
diagnosable, and removable.

## Scope

This package manages the local integration layer only:

    Obsidian
      -> Local REST API
      -> tunnel-client
      -> MCP endpoint
      -> ChatGPT

It does NOT install Obsidian, the Obsidian Local REST API plugin, or the
tunnel-client binary itself. Those remain external dependencies.

## Commands

    ./bin/doctor.sh
    ./bin/install.sh
    ./bin/uninstall.sh

`install.sh` is intentionally conservative. It creates the toolkit directory
and a configuration template, but it does not overwrite an existing
`tunnel-client` configuration.

## Design rule

v0.1.0 is deliberately boring:
- reproducible
- diagnosable
- removable
- no Docker
- no Mem0
- no Qdrant
- no automatic credential generation
- no destructive cleanup by default
