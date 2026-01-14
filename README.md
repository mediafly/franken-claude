# franken-claude

A wrapper to launch sandboxed Claude Code containers in OrbStack/Docker with AWS SSO credential injection.

## Features

- Runs Claude Code CLI in isolated Docker containers
- Automatic AWS SSO credential injection (temporary credentials only)
- Web-based terminal via ttyd with browser notifications
- Each terminal tab gets its own git worktree for parallel work
- Pre-configured MCP servers (context7, sequential-thinking, aws-documentation, aws-knowledge, aws-core)
- Desktop notifications when Claude is waiting for user input

## Prerequisites

- Docker or OrbStack
- AWS CLI v2 with SSO configured
- A git repository to work with

## Installation

```bash
git clone https://github.com/mediafly/franken-claude.git
cd franken-claude

# Copy and configure MCP settings (optional, for local development)
cp .claude/settings.local.json.example .claude/settings.local.json
# Edit .claude/settings.local.json to add your context7 API key

# Install franken CLI globally (optional, but recommended)
sudo cp franken /usr/local/bin/franken
```

**Note:** If you don't install globally, use `./franken` instead of `franken` for all commands below.

## Usage

The `franken` CLI provides commands to manage franken-claude containers:

### Start a container

```bash
franken start --profile <aws-profile> --repo <path-to-git-repo> [--read-only]
```

**Options:**
- `--profile, -p`: AWS SSO profile name, or `all` to mount entire `~/.aws` directory
- `--repo, -r`: Path to git repository to mount
- `--read-only`: Mount repository as read-only (optional)

**Examples:**
```bash
# Start with specific profile
franken start --profile dev --repo ~/projects/my-app

# Start with all AWS profiles available (mounts ~/.aws)
franken start --profile all --repo ~/projects/my-app

# Start in read-only mode
franken start --profile dev --repo ~/projects/my-app --read-only
```

This will:
1. Check AWS SSO credentials (auto-triggers `aws sso login` if expired, unless using `--profile all`)
2. Build the Docker image (first run only)
3. Start a container named `franken-<profile>-<n>`
4. Open a web terminal in your browser at `http://localhost:7681`

Each new browser tab to the same URL creates a new git worktree (`franken-1`, `franken-2`, etc.).

### List containers

```bash
franken list
```

Shows all franken-claude containers with their status, port, and uptime.

### View logs

```bash
franken logs <container-name>           # View logs
franken logs <container-name> -f        # Follow logs
franken logs <container-name> --tail 50 # Last 50 lines
```

### Execute commands

```bash
franken exec <container-name> "command"  # Run a command
franken exec <container-name>            # Interactive bash shell
```

### Stop containers

```bash
franken stop <container-name>        # Stop specific container
franken stop <profile>               # Stop all containers for profile
franken stop --all                   # Stop all franken-claude containers
```

Stopping automatically cleans up git worktrees and saves the container state to a timestamped image.

### Rebuild image

```bash
franken rebuild
```

Rebuilds the Docker image from scratch (useful after updating Dockerfile or scripts).

### Get help

```bash
franken help                    # Show all commands
franken <command> --help        # Show help for specific command
```

## Environment Variables

Set these on your host machine before running `franken start`:

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

## What's in the container

- debian:bookworm-slim base
- Claude Code CLI
- ttyd (web terminal)
- git, gh, curl, jq
- AWS CLI v2
- uv (Python package manager)
- Pre-configured MCP servers

## License

MIT
