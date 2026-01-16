# frank-claude

A wrapper to launch sandboxed Claude Code containers in OrbStack/Docker with AWS SSO credential injection.

## Features

- Runs Claude Code CLI in isolated Docker containers
- Automatic AWS SSO credential injection (temporary credentials only)
- Web-based terminal via ttyd with browser notifications
- Each terminal tab gets its own git worktree for parallel work
- Pre-configured MCP servers (context7, sequential-thinking, aws-documentation, aws-knowledge, aws-core)
- Desktop notifications when Claude is waiting for user input
- Persistent Claude data storage (session history, settings) across container restarts

## Prerequisites

- Docker or OrbStack
- AWS CLI v2 with SSO configured
- A git repository to work with

## Installation

```bash
git clone https://github.com/mediafly/frank-claude.git
cd frank-claude

# Copy and configure MCP settings (optional, for local development)
cp .claude/settings.local.json.example .claude/settings.local.json
# Edit .claude/settings.local.json to add your context7 API key

# Install frank CLI globally (optional, but recommended)
sudo cp frank /usr/local/bin/frank
```

**Note:** If you don't install globally, use `./frank` instead of `frank` for all commands below.

## Usage

The `frank` CLI provides commands to manage frank-claude containers:

### Start a container

```bash
frank start --profile <aws-profile> --repo <path-to-git-repo> [--read-only]
```

**Options:**
- `--profile, -p`: AWS SSO profile name, or `all` to mount entire `~/.aws` directory
- `--repo, -r`: Path to git repository to mount
- `--read-only`: Mount repository as read-only (optional)

**Examples:**
```bash
# Start with specific profile
frank start --profile dev --repo ~/projects/my-app

# Start with all AWS profiles available (mounts ~/.aws)
frank start --profile all --repo ~/projects/my-app

# Start in read-only mode
frank start --profile dev --repo ~/projects/my-app --read-only
```

This will:
1. Check AWS SSO credentials (auto-triggers `aws sso login` if expired, unless using `--profile all`)
2. Build the Docker image (first run only)
3. Start a container named `frank-<profile>-<n>`
4. Open a web terminal in your browser at `http://localhost:7681`

Each new browser tab to the same URL creates a new git worktree (`frank-1`, `frank-2`, etc.).

### List containers

```bash
frank list
```

Shows all frank-claude containers with their status, port, and uptime.

### View logs

```bash
frank logs <container-name>           # View logs
frank logs <container-name> -f        # Follow logs
frank logs <container-name> --tail 50 # Last 50 lines
```

### Execute commands

```bash
frank exec <container-name> "command"  # Run a command
frank exec <container-name>            # Interactive bash shell
```

### Stop containers

```bash
frank stop <container-name>        # Stop specific container
frank stop <profile>               # Stop all containers for profile
frank stop --all                   # Stop all frank-claude containers
```

Stopping automatically cleans up git worktrees and saves the container state to a timestamped image.

### Rebuild image

```bash
frank rebuild
```

Rebuilds the Docker image from scratch (useful after updating Dockerfile or scripts).

### Get help

```bash
frank help                    # Show all commands
frank <command> --help        # Show help for specific command
```

## Environment Variables

Set these on your host machine before running `frank start`:

| Variable | Required | Description |
|----------|----------|-------------|
| `CLAUDE_OAUTH_TOKEN` | Recommended | Claude subscription OAuth token for auto-authentication. Get this by running `claude setup-token` on your host machine. |
| `CONTEXT7_API_KEY` | Optional | API key for the context7 MCP server. Get one at [context7.com/dashboard](https://context7.com/dashboard). |

### Setting up Claude authentication

To avoid having to authenticate in the browser every time you launch a container:

1. Run `claude setup-token` on your host machine and follow the prompts
2. Copy the token value
3. Set it as an environment variable:
   ```bash
   # Add to your ~/.bashrc, ~/.zshrc, or equivalent
   export CLAUDE_OAUTH_TOKEN="your-token-here"
   ```
4. The token will be automatically injected into containers at launch

## Browser Notifications

The web terminal includes desktop notification support to alert you when Claude is waiting for input. This is especially useful when working in other windows or tabs.

### How it works

- When you first access the terminal, your browser will request permission to show notifications
- Notifications are triggered when Claude displays prompts like "continue", "approve", "proceed", or questions
- A 5-second cooldown prevents notification spam
- Clicking a notification brings the terminal window into focus

### Toggle notifications

Press `Ctrl+Shift+N` to enable/disable notifications. The notification status will briefly appear in the top-right corner.

### Notification patterns

The system detects these common Claude prompt patterns:
- Questions ending with `?`
- Keywords: "continue", "approve", "proceed", "waiting", "input", "response"
- Extended inactivity when the window is unfocused (30+ seconds)

## Data Persistence

Claude Code session data, conversation history, and settings are automatically persisted across container restarts. Each container gets its own isolated data directory on your host machine.

**Storage location:** `~/.claude-containers/<container-name>/`

This directory contains:
- Conversation history and session state
- Claude Code settings and preferences
- MCP server configurations
- Any other Claude-related data

**Benefits:**
- Resume conversations after restarting containers
- Maintain your settings and preferences
- Each container's data is isolated from others
- Easy to back up or inspect on the host machine

**Managing storage:**
```bash
# View all container data directories
ls -la ~/.claude-containers/

# Back up a container's data
cp -r ~/.claude-containers/frank-dev-1 ~/backups/

# Remove data for stopped containers
rm -rf ~/.claude-containers/frank-old-container
```

## Using MCP Launchpad

The container includes [mcp-launchpad](https://github.com/kenneth-liao/mcp-launchpad), a lightweight CLI for efficiently discovering and executing tools from multiple MCP servers.

**Available commands:**
- `mcp-launchpad` - Full command
- `mcpl` - Short alias

**Features:**
- Unified tool discovery across all configured MCP servers
- BM25 search, regex matching, or exact matching
- Persistent server connections through a session daemon
- Automatic configuration loading from Claude settings

**Example usage:**
```bash
# Inside a frank-claude container
mcpl search "aws"           # Find AWS-related tools
mcpl list                   # List all available tools
mcpl execute <tool-name>    # Execute a specific tool
```

The tool automatically reads your MCP server configuration from `/root/.claude/settings.local.json`.

## What's in the container

- debian:bookworm-slim base
- Claude Code CLI
- ttyd (web terminal)
- git, gh, curl, jq
- AWS CLI v2
- Python 3.13
- uv (Python package manager)
- mcp-launchpad (MCP server tool discovery CLI)
- Pre-configured MCP servers

## License

MIT
