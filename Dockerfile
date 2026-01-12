FROM debian:bookworm-slim

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    git \
    jq \
    ca-certificates \
    gnupg \
    unzip \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Install ttyd (web terminal)
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then TTYD_ARCH="x86_64"; else TTYD_ARCH="aarch64"; fi && \
    curl -L "https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.${TTYD_ARCH}" -o /usr/local/bin/ttyd \
    && chmod +x /usr/local/bin/ttyd

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Pre-install MCP server npm packages for faster startup
RUN npm install -g @upstash/context7-mcp @modelcontextprotocol/server-sequential-thinking

# Create workspace directory
RUN mkdir -p /workspace /worktrees

# Configure Claude Code MCP servers
RUN mkdir -p /root/.claude
COPY claude-settings.json /root/.claude/settings.local.json

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy terminal init script (creates worktree and cd's into it)
COPY terminal-init.sh /terminal-init.sh
RUN chmod +x /terminal-init.sh

WORKDIR /workspace

EXPOSE 7681

ENTRYPOINT ["/entrypoint.sh"]
