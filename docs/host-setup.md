# Host Setup Guide

One-time setup steps for your macOS host before opening the devcontainer for the first time.

---

## 1. Export required API keys

The container receives all secrets via `remoteEnv` — nothing is baked into the image.
Add these exports to your `~/.zshrc` or `~/.aliases.zsh` and source the file:

```bash
# Anthropic / Claude
export ANTHROPIC_API_KEY="sk-ant-..."
export ANTHROPIC_MODEL="claude-opus-4-5"
export ANTHROPIC_SMALL_FAST_MODEL="claude-haiku-4-5-20251001"

# OpenAI / Codex
export OPENAI_API_KEY="sk-..."
export OPENAI_ORG_ID="org-..."

# 1Password CLI (see section 2)
export OP_SERVICE_ACCOUNT_TOKEN="ops1_..."

# MCP server keys
export CONTEXT7_API_KEY="..."
export EXA_API_KEY="..."
export TAVILY_API_KEY="..."
export FIRECRAWL_API_KEY="..."
export PERPLEXITY_API_KEY="..."
export BRAVE_API_KEY="..."
export REF_API_KEY="..."
```

The container silently passes through any variable that isn't set — tools that depend on
missing keys will fail at runtime, not at container build time.

---

## 2. 1Password CLI setup

The container uses **1Password Service Account** authentication. This is the correct
approach when the host has no 1Password desktop app socket to mount (OrbStack containers
can't access the macOS GUI app socket).

### Create a service account token

1. Open [1Password.com](https://1password.com) → your account → **Developer Tools** → **Service Accounts**
2. Click **New Service Account**
3. Give it a name (e.g., `devcontainer`)
4. Grant access to the vaults the container needs (e.g., `cloudflare`, `porkbun`, `dev`)
5. Click **Generate Token** — copy it immediately (shown only once)

Docs: [developer.1password.com/docs/service-accounts](https://developer.1password.com/docs/service-accounts/)

### Export the token

```bash
# Add to ~/.zshrc or ~/.aliases.zsh (already listed in section 1):
export OP_SERVICE_ACCOUNT_TOKEN="ops1_..."
```

### Verify inside the container

```bash
op whoami
# Should print: account URL, user ID, and service account name
```

---

## 3. Verify required host directories exist

The devcontainer mounts several directories from your home folder. Most are created by their
respective tools, but check before first use:

```bash
ls ~/.claude          # Claude Code config — must exist
ls ~/.claude.json     # Claude Code account — created on first claude login
ls ~/.agents          # Skills + agent definitions
ls ~/.ssh             # SSH keys
ls ~/.gitconfig       # Git identity (file, not a dir)
ls ~/.config/gh       # GitHub CLI auth
ls ~/.gemini          # Gemini CLI — created on first gemini run
ls ~/.codex           # Codex CLI — created on first codex run
ls ~/.openclaw        # openclaw — created on first run
ls ~/.config/opencode
ls ~/.local/share/opencode
ls ~/.orbstack/run/docker.sock   # OrbStack Docker socket
```

Directories that don't exist will cause the container to fail to start. Create missing ones:

```bash
mkdir -p ~/.agents ~/.gemini ~/.codex ~/.openclaw ~/.config/opencode ~/.local/share/opencode
```

---

## 4. Open the container

```bash
cd ~/github/joeblackwaslike/devcontainer
code .
# VS Code: "Dev Containers: Reopen in Container"
```

The first open pulls `ghcr.io/joeblackwaslike/devcontainer:latest` from GHCR. Subsequent
opens are fast (image is cached locally).

---

## 5. Add this environment to another project

Use `just init` (or `scripts/install.sh` directly) to install a dev container template
into any project. The script is interactive — it asks which template you want and any
configuration before applying.

```bash
cd ~/github/joeblackwaslike/devcontainer

# Interactive install into a project
just init ~/github/myproject

# Or run the script directly
bash scripts/install.sh ~/github/myproject

# Preview without writing
bash scripts/install.sh ~/github/myproject --dry-run

# Overwrite an existing .devcontainer/
bash scripts/install.sh ~/github/myproject --force
```

The script prompts for:
1. **Template** — `claude-code` (image-only, recommended) or `claude-code-extend` (add a Dockerfile)
2. **Container name** — defaults to the project directory name
3. **`.gitignore`** — optionally adds `.devcontainer/` (config is maintained centrally here)

See [discover-deps.md](discover-deps.md) for how to customise per-project setup via
`custom-setup.sh`.

---

## 6. Build and publish the image

Build locally and push to GHCR after any change to `image/Dockerfile`.

### Authenticate to GHCR

```bash
# Generate a token at https://github.com/settings/tokens
# Scopes required: write:packages, read:packages, delete:packages
echo $GITHUB_TOKEN | docker login ghcr.io -u joeblackwaslike --password-stdin
```

### Build and push

```bash
just push   # multi-arch (linux/amd64 + linux/arm64) → ghcr.io/joeblackwaslike/devcontainer:latest
```

### Make the package public (one-time after first push)

Go to `https://github.com/users/joeblackwaslike/packages/container/devcontainer/settings`
and set visibility to **Public** so projects can pull without authentication.

---

## 7. Publish templates (after template changes)

After modifying anything in `src/`:

```bash
export CR_PAT="<github-token-with-write:packages>"
just publish-templates
```

This publishes `ghcr.io/joeblackwaslike/claude-code` and
`ghcr.io/joeblackwaslike/claude-code-extend` to GHCR as OCI artifacts.
See [devcontainer-templates-spec.md](devcontainer-templates-spec.md) for the full spec.
