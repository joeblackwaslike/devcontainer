# devcontainer

[![Discord](https://img.shields.io/discord/1486035859747897414?logo=discord&label=Discord&color=5865F2)](https://discord.com/channels/1486035859747897414/1509515345856167938) [![Join Discord](https://img.shields.io/badge/Discord-Join%20Server-5865F2?logo=discord&logoColor=white)](https://discord.gg/Fjc9zYHZyV)

A Claude Code/Codex/gemini optimised development environment for any project. Mirrors the local macOS toolchain inside a Linux container so Claude Code and agents can run with `--dangerously-skip-permissions` with a contained blast radius.

---

## Features

- **Full language toolchain** — Python 3, Node LTS, Ruby 4, Go, Rust, Bun, Deno, pnpm, Deno via [asdf](https://asdf-vm.com/)
- **AI / agent tools** — Claude Code, Gemini CLI, Codex CLI, beads task manager, gastown multi-agent workspace manager
- **Fast package manager** — `uv` for Python, `pnpm`/`bun`/`yarn` for Node, `cargo` for Rust
- **Modern CLI tooling** — eza, bat, ripgrep, fzf, delta, dust, glow, hyperfine, just
- **Databases** — PostgreSQL 18, Redis, SQLite, Dolt (versioned SQL)
- **TLS / secrets** — mkcert local CA, Smallstep CLI, 1Password CLI (`op`)
- **Cloud CLIs** — AWS CLI v2, gcloud, Supabase CLI
- **Docker-in-Docker** — run containers inside the container (OrbStack socket mounted)
- **Host identity mirrored** — SSH keys, git config, GitHub CLI auth, MCP API keys all passed through
- **Per-project dep discovery** — auto-installs dependencies on every attach (Node, Python, Rust, Go, Ruby)
- **Project bootstrap CLI** — `just init` installs the dev container into any repo in seconds, with an interactive template picker

---

## Prerequisites

Follow [`docs/host-setup.md`](docs/host-setup.md) before opening the container for the first time:

1. Export required API keys in your shell
2. Generate a 1Password service account token and export `OP_SERVICE_ACCOUNT_TOKEN`
3. Verify required host directories exist

---

## Quick start

### Use this repo directly

```bash
git clone git@github.com:joeblackwaslike/devcontainer.git ~/github/joeblackwaslike/devcontainer
cd ~/github/joeblackwaslike/devcontainer
code .
# VS Code: "Dev Containers: Reopen in Container"
```

### Add to an existing project

Run from the `devcontainer/` repo root — the script is interactive and asks which template
you want and how to name the container:

```bash
just init ~/github/myproject
```

Or call the script directly for extra options:

```bash
bash scripts/install.sh ~/github/myproject          # interactive
bash scripts/install.sh ~/github/myproject --force  # overwrite existing .devcontainer/
bash scripts/install.sh ~/github/myproject --dry-run # preview without writing
```

The script asks:
1. **Template** — `claude-code` (pre-built image, recommended) or `claude-code-extend` (add a custom Dockerfile layer)
2. **Container name** — defaults to the project directory name
3. **`.gitignore`** — optionally excludes `.devcontainer/` since the config lives centrally here

Then open VS Code in the target project and choose **Dev Containers: Reopen in Container**.

---

## Repository layout

```
devcontainer/
├── image/                          # Docker build context → ghcr.io/joeblackwaslike/devcontainer
│   ├── Dockerfile                  # Image definition — all tool installs
│   ├── Aptfile                     # System packages (apt)
│   ├── .zshrc                      # Shell config baked into the image
│   ├── .mytheme.omp.yaml           # oh-my-posh prompt theme
│   └── scripts/
│       ├── setup.sh                # Post-create: skills symlink, mkcert CA
│       └── discover-deps.sh        # Post-attach: auto-install repo deps
├── src/                            # Dev Container Templates (published to GHCR)
│   ├── claude-code/                # Template: use pre-built image directly
│   │   ├── devcontainer-template.json
│   │   └── .devcontainer/
│   │       ├── devcontainer.json
│   │       └── custom-setup.sh     # Project-specific hook stub
│   └── claude-code-extend/         # Template: extend with a project Dockerfile
│       ├── devcontainer-template.json
│       └── .devcontainer/
│           ├── devcontainer.json
│           ├── Dockerfile          # FROM ghcr.io/joeblackwaslike/devcontainer:latest
│           └── custom-setup.sh
├── scripts/
│   └── install.sh                  # Interactive template installer
├── .devcontainer/
│   └── devcontainer.json           # This repo's own container config
├── docs/                           # Reference documentation
├── justfile                        # build, push, shell, init, publish-templates
└── README.md                       # This file
```

---

## Documentation

| Doc | What it covers |
| --- | --- |
| [docs/host-setup.md](docs/host-setup.md) | First-time host setup: API keys, 1Password CLI, directory checks, publishing |
| [docs/tools.md](docs/tools.md) | Complete catalog of every installed tool, version strategy, and install method |
| [docs/discover-deps.md](docs/discover-deps.md) | Per-project dependency auto-detection and customisation |
| [docs/devcontainer-json-reference.md](docs/devcontainer-json-reference.md) | Full devcontainer.json property and lifecycle hook reference |
| [docs/devcontainer-templates-spec.md](docs/devcontainer-templates-spec.md) | Dev Container Templates authoring and publishing spec |
| [docs/devcontainer-features-spec.md](docs/devcontainer-features-spec.md) | Dev Container Features authoring and publishing spec |

---

## How the environment works

### Mounts

All mounts are read-only unless the tool needs to write state to the path.

| Mount | Mode | Purpose |
| --- | --- | --- |
| `~/.claude` | read-write | Claude Code sessions, memory, settings, plugins |
| `~/.claude.json` | read-write | Claude Code account config |
| `~/.agents` | read-only | Shared skills and agent definitions |
| `~/.ssh` | read-only | SSH keys |
| `~/.gitconfig` | read-only | Git identity |
| `~/.config/gh` | read-only | GitHub CLI auth |
| `~/github/joeblackwaslike` | read-only | Local repos (resolves MCP server paths) |
| `~/.gemini` | read-write | Gemini CLI state |
| `~/.codex` | read-write | Codex CLI state |
| `~/.openclaw` | read-write | openclaw state |
| `~/.config/opencode` | read-write | opencode settings |
| `~/.local/share/opencode` | read-write | opencode runtime data |
| `~/.orbstack/run/docker.sock` | read-write | Docker socket |

### API keys

All keys are forwarded via `remoteEnv` in `devcontainer.json`. Nothing is baked into the
image — export keys in your shell before opening the container.

### MCP server path compatibility

`settings.json` on the host contains paths like
`/Users/joe/github/joeblackwaslike/mcp-exec/dist/src/server.js`. The Dockerfile adds
`ln -sf /home/vscode /Users/joe` so these paths resolve inside the container once
`~/github/joeblackwaslike` is mounted.

---

## Updating tools

- **apt packages**: edit `image/Aptfile`, rebuild the image
- **asdf runtimes**: edit the version in `image/Dockerfile` `asdf install` block, rebuild
- **npm globals / cargo / go installs**: edit the corresponding `RUN` block in `image/Dockerfile`, rebuild
- **Document every change** in the `## Changelog` section of [`docs/tools.md`](docs/tools.md)
