# Dev Container Features Specification

> Source: https://containers.dev/implementors/features/

## Overview

Features are self-contained, shareable units of installation code and dev container
configuration that quickly add tooling, runtimes, or libraries to a dev container. Each
Feature is a metadata file + installation script.

## Folder Structure

```
feature/
  devcontainer-feature.json   ← metadata
  install.sh                  ← entrypoint (runs as root at image build time)
  [other files]
```

## devcontainer-feature.json Properties

### Core (required)

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Unique identifier — must match directory name |
| `version` | string | Semantic version |
| `name` | string | Human-friendly display name |

### Configuration (optional)

| Property | Type | Description |
|----------|------|-------------|
| `description` | string | Feature description |
| `options` | object | Map of options passed as env vars to `install.sh` |
| `containerEnv` | object | Name-value pairs setting/overriding environment variables |
| `privileged` | boolean | Enables privileged mode |
| `init` | boolean | Adds tini init process |
| `capAdd` | array | Linux kernel capabilities |
| `securityOpt` | array | Security options |
| `entrypoint` | string | Script executing at container startup |
| `mounts` | object | Cross-orchestrator mount configuration |
| `customizations` | object | Product-specific namespace properties |

### Dependency & Installation

| Property | Type | Description |
|----------|------|-------------|
| `dependsOn` | object | Hard dependencies — must install before this Feature |
| `installsAfter` | array | Soft ordering hints for already-queued Features |
| `legacyIds` | array | Previously used IDs (for renames) |
| `deprecated` | boolean | Marks Feature as no longer maintained |

## Lifecycle Hooks in Features

Features support the same lifecycle hooks as `devcontainer.json`:

- `onCreateCommand`
- `updateContentCommand`
- `postCreateCommand`
- `postStartCommand`
- `postAttachCommand`

Each accepts string, array, or object format. **Feature lifecycle commands always run
before the user-provided commands in `devcontainer.json`.**

### Writing Scripts to Known Paths (key pattern)

Features can write helper scripts during `install.sh` (build time) for use in lifecycle
hooks:

```bash
# In install.sh
SCRIPT_PATH="/usr/local/share/devcontainer/scripts/setup.sh"
mkdir -p "$(dirname "$SCRIPT_PATH")"
tee "$SCRIPT_PATH" > /dev/null << 'EOF'
#!/bin/sh
# runs at postCreateCommand time
mkcert -install
EOF
chmod +x "$SCRIPT_PATH"
```

Then in `devcontainer-feature.json`:
```json
{
  "postCreateCommand": "/usr/local/share/devcontainer/scripts/setup.sh"
}
```

## Options

Options are passed as uppercase environment variables to `install.sh`:

```json
"options": {
  "version": {
    "type": "string",
    "enum": ["latest", "3.10", "3.9"],
    "default": "latest"
  },
  "pip": {
    "type": "boolean",
    "default": true
  }
}
```

Produces env vars: `VERSION="3.10"`, `PIP="false"` (unspecified options use defaults).

## User Environment Variables in install.sh

| Variable | Description |
|----------|-------------|
| `_REMOTE_USER` | Configured remote user |
| `_CONTAINER_USER` | Container's user account |
| `_REMOTE_USER_HOME` | Remote user's home directory |
| `_CONTAINER_USER_HOME` | Container user's home directory |

## Installation Order

Features install in tool-determined order, influenced by:

1. **`dependsOn`** — hard recursive dependencies, must be satisfied first
2. **`installsAfter`** — soft ordering for already-queued Features
3. **`overrideFeatureInstallOrder`** in `devcontainer.json` — user-controlled priority

## Publishing

```bash
GITHUB_TOKEN="$CR_PAT" devcontainer features publish \
  -r ghcr.io \
  -n joeblackwaslike \
  ./src
```

OCI naming: `ghcr.io/<namespace>/<feature-id>[:version]`

## Referencing Features

```json
"features": {
  "ghcr.io/devcontainers/features/node:1": { "version": "20" },
  "./myLocalFeature": { "optionA": true },
  "https://github.com/user/repo/releases/feature.tgz": {}
}
```
