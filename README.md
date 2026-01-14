# franken-claude

A wrapper to launch sandboxed Claude Code containers in OrbStack/Docker with AWS SSO credential injection.

## Features

- Runs Claude Code CLI in isolated Docker containers
- Automatic AWS SSO credential injection (temporary credentials only)
- Web-based terminal via ttyd
- Each terminal tab gets its own git worktree for parallel work
- Pre-configured MCP servers (context7, sequential-thinking, aws-documentation, aws-knowledge, aws-core)

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

# Install fc CLI globally (optional, but recommended)
sudo cp fc /usr/local/bin/fc
```

**Note:** If you don't install globally, use `./fc` instead of `fc` for all commands below.

## Usage

The `fc` CLI provides commands to manage franken-claude containers:

### Start a container

```bash
fc start --profile <aws-profile> --repo <path-to-git-repo>
```

This will:
1. Check AWS SSO credentials (auto-triggers `aws sso login` if expired)
2. Build the Docker image (first run only)
3. Start a container named `franken-<profile>-<n>`
4. Open a web terminal in your browser at `http://localhost:7681`

Each new browser tab to the same URL creates a new git worktree (`franken-1`, `franken-2`, etc.).

### List containers

```bash
fc list
```

Shows all franken-claude containers with their status, port, and uptime.

### View logs

```bash
fc logs <container-name>           # View logs
fc logs <container-name> -f        # Follow logs
fc logs <container-name> --tail 50 # Last 50 lines
```

### Execute commands

```bash
fc exec <container-name> "command"  # Run a command
fc exec <container-name>            # Interactive bash shell
```

### Stop containers

```bash
fc stop <container-name>        # Stop specific container
fc stop <profile>               # Stop all containers for profile
fc stop --all                   # Stop all franken-claude containers
```

Stopping automatically cleans up git worktrees and saves the container state to a timestamped image.

### Rebuild image

```bash
fc rebuild
```

Rebuilds the Docker image from scratch (useful after updating Dockerfile or scripts).

### Get help

```bash
fc help                    # Show all commands
fc <command> --help        # Show help for specific command
```

## Environment Variables

Set these on your host machine before running `fc start`:

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
