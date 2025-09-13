# Claude Configuration

This directory contains Claude Code CLI configuration, including MCP (Model Context Protocol) server setup.

## Files

- `settings.json` - Claude Code CLI settings (goes to `~/.claude/settings.json`)
- `install.sh` - Script to install this config to proper location

## Important Notes

### MCP Server Paths
The MCP server configuration contains paths that are specific to your machine setup. You'll need to update these paths after installing on a new machine:

**In `settings.json`:**
- Update `cwd` path for the zen-mcp-server location
- Update `PYTHONPATH` to match

Current path: `~/.local/share/mcp-servers/zen-mcp-server`

### Installation

```bash
./install.sh
```

After installation, edit the paths in the installed configs if needed.