# devcontainer — CLAUDE.md

## What this repo is

A Claude Code–optimised development container for any project. It packages a full
multi-language toolchain, AI/agent CLIs, and host-identity passthrough into a single
VS Code Dev Container image. The goal is to let Claude Code and other agents run with
`--dangerously-skip-permissions` at a contained blast radius.

This is a **configuration repo** — there is no application source code, no test suite,
and no build artefact beyond a Docker image.

---

## Repository layout

```
image/                          ← Docker build context → produces devcontainer:latest
  Dockerfile                    ← Image definition — all tool installs live here
  Aptfile                       ← apt packages (consumed by bash-aptfile)
  .zshrc                        ← Shell config copied into the image
  .mytheme.omp.yaml             ← oh-my-posh prompt theme
  scripts/
    setup.sh                    ← postCreateCommand — mkcert CA, skills symlink
    discover-deps.sh            ← postAttachCommand — auto-installs project deps

src/                            ← Dev Container Templates (published to GHCR)
  claude-code/                  ← Template: image-only (most projects)
    devcontainer-template.json
    .devcontainer/
      devcontainer.json         ← "image": "ghcr.io/joeblackwaslike/devcontainer:latest"
      custom-setup.sh           ← stub for project-specific hook
  claude-code-extend/           ← Template: Dockerfile variant (layer extra tools)
    devcontainer-template.json
    .devcontainer/
      devcontainer.json         ← "build": { "dockerfile": "Dockerfile" }
      Dockerfile                ← FROM ghcr.io/joeblackwaslike/devcontainer:latest
      custom-setup.sh           ← stub for project-specific hook

.devcontainer/
  devcontainer.json             ← This repo's own container; uses the published image

docs/                           ← Reference documentation
  devcontainer-json-reference.md    ← Full devcontainer.json property reference
  devcontainer-templates-spec.md    ← Template authoring + publishing spec
  devcontainer-features-spec.md     ← Feature authoring + publishing spec
  packages-to-add.md               ← Candidate packages for future Aptfile additions

justfile                        ← build, push, shell, init, publish-templates
README.md                       ← Project overview
CLAUDE.md                       ← This file
AGENTS.md                       ← Agent instructions (delegates here)
```

---

## Common commands

```bash
just build              # Build image locally as joeblackwaslike/devcontainer:latest
just push               # Build multi-arch (amd64 + arm64) and push to GHCR
just shell              # Open an interactive zsh shell in the local image
just init [target]      # Apply claude-code template to a project (default: current dir)
just publish-templates  # Publish src/ templates to GHCR (requires CR_PAT)
```

---

## How to make changes

| What you want to change | Where to edit |
|---|---|
| System apt package | `image/Aptfile` |
| asdf runtime version | `image/Dockerfile` — the `asdf install <plugin> <version>` line |
| npm global tool | `image/Dockerfile` — the `npm install -g` RUN block |
| Rust/cargo tool | `image/Dockerfile` — the `cargo install` RUN block |
| Go tool | `image/Dockerfile` — the `GOPATH=/usr/local go install` RUN block |
| Python pipx tool | `image/Dockerfile` — the `pipx install` RUN block |
| VS Code extensions | `src/claude-code/.devcontainer/devcontainer.json` — extensions array (then copy to claude-code-extend) |
| Environment variable forwarded | `src/claude-code/.devcontainer/devcontainer.json` — `remoteEnv` (then copy to claude-code-extend) |
| Mount | `src/claude-code/.devcontainer/devcontainer.json` — `mounts` (then copy to claude-code-extend) |
| Shell config / aliases | `image/.zshrc` |
| Post-create one-time setup | `image/scripts/setup.sh` |
| Per-project dep auto-detection | `image/scripts/discover-deps.sh` |

**Always document tool additions and removals in the `## Changelog` section of
`.devcontainer/TOOLS.md`.**

After any `image/Dockerfile` change, rebuild with `just build` and smoke-test with `just shell`.

---

## Architecture notes

### Runtime manager: asdf

All language runtimes (Python, Node, Ruby, Go, Rust, Bun, Deno, pnpm, AWS CLI,
gcloud, pipx, Supabase CLI, yarn, jq, yq, just) are installed via asdf.

- `ASDF_DATA_DIR=/home/vscode/.asdf` — set in Dockerfile and mounted at that exact path
- `/home/vscode/.tool-versions` — written during image build so shims resolve at runtime
- Shims are on `PATH` via `ENV PATH=/home/vscode/.asdf/shims:/home/vscode/.asdf/bin:...`

### Lifecycle scripts

`setup.sh` and `discover-deps.sh` are baked into the image at
`/usr/local/share/devcontainer/scripts/` during the Docker build. Template
`devcontainer.json` files reference them directly — no scripts are copied per-project.
Updating a script requires rebuilding and pushing the image.

### MCP path compatibility

Claude Code's `settings.json` on the host contains macOS paths like
`/Users/joe/github/joeblackwaslike/mcp-exec/dist/src/server.js`. The Dockerfile
creates `ln -sf /home/vscode /Users/joe` so these paths resolve once
`~/github/joeblackwaslike` is mounted read-only at `/home/vscode/github/joeblackwaslike`.

### 1Password

This macOS host has no 1Password agent socket to mount. Authentication uses a service
account token exported as `OP_SERVICE_ACCOUNT_TOKEN` before opening the container.
The token is forwarded via `remoteEnv` — never baked into the image.

### Mounts summary

| Mount target | Mode | Purpose |
|---|---|---|
| `~/.claude` | read-write | Claude Code sessions, memory, plugins |
| `~/.claude.json` | read-write | Claude Code account config |
| `~/.agents` | read-only | Shared skills and agent definitions |
| `~/.ssh` | read-only | SSH keys |
| `~/.gitconfig` | read-only | Git identity |
| `~/.config/gh` | read-only | GitHub CLI auth |
| `~/github/joeblackwaslike` | read-only | Local repos (MCP path resolution) |
| `~/.gemini` | read-write | Gemini CLI state |
| `~/.codex` | read-write | Codex CLI state |
| `~/.openclaw` | read-write | openclaw state |
| `~/.config/opencode` | read-write | opencode settings |
| `~/.local/share/opencode` | read-write | opencode runtime data |
| `~/.orbstack/run/docker.sock` | read-write | Docker socket (OrbStack) |

---

## Template publishing

Templates in `src/` publish to GHCR as OCI artifacts:

- `ghcr.io/joeblackwaslike/claude-code` — image-only template
- `ghcr.io/joeblackwaslike/claude-code-extend` — Dockerfile variant

```bash
# Requires CR_PAT env var with write:packages scope
just publish-templates
```

Apply to a new project:
```bash
just init ~/github/myproject
# or directly:
devcontainer templates apply \
  -t ghcr.io/joeblackwaslike/claude-code \
  -a '{"containerName": "myproject"}' \
  -w ~/github/myproject
```

---

## Agent guidance

- This repo has no unit tests — correctness is verified by building the image and
  running `just shell`.
- Build context is `image/` — not `.devcontainer/`. Use `just build`, not docker directly.
- When adding a new tool: edit `image/Dockerfile`, update `.devcontainer/TOOLS.md`
  changelog, rebuild.
- When removing a tool: remove from Dockerfile AND from `TOOLS.md` catalog entry,
  update changelog.
- When changing mounts or remoteEnv: update BOTH `src/claude-code/.devcontainer/devcontainer.json`
  AND `src/claude-code-extend/.devcontainer/devcontainer.json` — they must stay in sync.
- Do not touch `src/*/devcontainer-template.json` version fields manually — bump version
  only when publishing a new release.
- `discover-deps.sh` is append-safe: adding a new project-type detector is low risk;
  changing existing detector logic can break existing projects.
