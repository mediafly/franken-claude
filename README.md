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
git clone https://github.com/yourusername/franken-claude.git
cd franken-claude

# Copy and configure MCP settings (optional, for local development)
cp .claude/settings.local.json.example .claude/settings.local.json
# Edit .claude/settings.local.json to add your context7 API key
```

## Usage

### Launch a container

```bash
./franken-claude --profile <aws-profile> --repo <path-to-git-repo>
```

This will:
1. Check AWS SSO credentials (auto-triggers `aws sso login` if expired)
2. Build the Docker image (first run only)
3. Start a container named `franken-<profile>-<n>`
4. Open a web terminal in your browser at `http://localhost:7681`

Each new browser tab to the same URL creates a new git worktree (`franken-1`, `franken-2`, etc.).

### Stop containers

```bash
# Stop a specific container
./franken-claude-stop franken-myprofile-1

# Stop all containers for a profile
./franken-claude-stop myprofile

# Stop all franken-claude containers
./franken-claude-stop --all
```

Stopping cleans up git worktrees automatically.

## Environment Variables

- `CONTEXT7_API_KEY` - Optional, passed to container for context7 MCP server

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
