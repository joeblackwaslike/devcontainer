# Dev Container Metadata Reference

> Source: https://containers.dev/implementors/json_reference/

## General Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | string | Display name for the dev container in the UI |
| `forwardPorts` 🏷️ | array | Ports to forward from container to local machine (e.g., `[3000, "db:5432"]`) |
| `portsAttributes` 🏷️ | object | Maps ports to default options; example: `"3000": {"label": "Application port"}` |
| `otherPortsAttributes` 🏷️ | object | Default options for unconfigured ports |
| `containerEnv` 🏷️ | object | Environment variables set on the Docker container itself |
| `remoteEnv` 🏷️ | object | Variables for the supporting tool/service but not the container as a whole |
| `remoteUser` 🏷️ | string | User that tools/services run as in the container |
| `containerUser` 🏷️ | string | User for all operations inside the container |
| `updateRemoteUserUID` 🏷️ | boolean | Update user UID/GID on Linux to match local user (default: true) |
| `userEnvProbe` 🏷️ | enum | Shell type for probing environment: `none`, `interactiveShell`, `loginShell`, `loginInteractiveShell` |
| `overrideCommand` 🏷️ | boolean | Whether to override container's default command (default: true for image, false for Compose) |
| `shutdownAction` 🏷️ | enum | `none`, `stopContainer` (image/Dockerfile default), or `stopCompose` (Compose default) |
| `init` 🏷️ | boolean | Use tini init process for zombie handling (default: false) |
| `privileged` 🏷️ | boolean | Run container in privileged mode (default: false) |
| `capAdd` 🏷️ | array | Add Linux capabilities, e.g., `["SYS_PTRACE"]` for debugging |
| `securityOpt` 🏷️ | array | Container security options, e.g., `["seccomp=unconfined"]` |
| `mounts` 🏷️ | string/object | Additional mounts supporting Docker CLI `--mount` syntax |
| `features` | object | Dev Container Feature IDs and options |
| `overrideFeatureInstallOrder` | array | Custom Feature installation order |
| `customizations` 🏷️ | object | Product-specific properties per supporting tools |

## Image/Dockerfile Properties

| Property | Type | Description |
|----------|------|-------------|
| `image` | string | Container registry image name (DockerHub, GitHub Container Registry, etc.) |
| `build.dockerfile` | string | Path to Dockerfile relative to `devcontainer.json` |
| `build.context` | string | Docker build context path (default: ".") |
| `build.args` | object | Build arguments passed to Docker; supports variable references |
| `build.options` | array | Docker build command options |
| `build.target` | string | Docker build target stage |
| `build.cacheFrom` | string/array | Images to use as cache during build |
| `appPort` | integer/string/array | Ports to publish locally; consider using `forwardPorts` instead |
| `workspaceMount` | string | Custom workspace mount point with Docker CLI syntax |
| `workspaceFolder` | string | Default path for tools to open in the container |
| `runArgs` | array | Docker CLI arguments for container execution |

## Docker Compose Properties

| Property | Type | Description |
|----------|------|-------------|
| `dockerComposeFile` | string/array | Path(s) to Docker Compose files relative to `devcontainer.json` |
| `service` | string | Service name to connect to after running |
| `runServices` | array | Services to start; defaults to all services |
| `workspaceFolder` | string | Default workspace path in container (default: "/") |

## Lifecycle Scripts

All commands execute from `workspaceFolder`. Failures prevent subsequent scripts from running.

| Property | Type | When it runs | Use case |
|----------|------|-------------|----------|
| `initializeCommand` | string/array/object | On **host** during initialization; may run multiple times | Host-side preflight |
| `onCreateCommand` 🏷️ | string/array/object | Inside container after first start; once | Cacheable setup (clone tools, etc.) |
| `updateContentCommand` 🏷️ | string/array/object | After source tree updates during creation | Dep installation — triggered by content changes |
| `postCreateCommand` 🏷️ | string/array/object | After user assignment; once; has access to user secrets | Final one-time setup (mkcert, symlinks) |
| `postStartCommand` 🏷️ | string/array/object | Each time container starts | Background services |
| `postAttachCommand` 🏷️ | string/array/object | Each time a tool attaches | Per-session tasks (dep sync on every attach) |
| `waitFor` 🏷️ | enum | — | Command to wait for before connecting (default: `updateContentCommand`) |

**String format** executes via `/bin/sh`; use `&&` for multiple commands.
**Array format** invokes directly without shell.
**Object format** allows parallel execution of multiple named commands.

## Variables in devcontainer.json

| Variable | Scope | Description |
|----------|-------|-------------|
| `${localEnv:VAR}` | Any | Host machine environment variable; supports `${localEnv:VAR:default}` |
| `${containerEnv:VAR}` | `remoteEnv` | Container env variable once running |
| `${localWorkspaceFolder}` | Any | Path to opened folder with `.devcontainer/devcontainer.json` |
| `${containerWorkspaceFolder}` | Any | Container workspace files path |
| `${localWorkspaceFolderBasename}` | Any | Folder name being opened |
| `${containerWorkspaceFolderBasename}` | Any | Container workspace folder name |
| `${devcontainerId}` | Multiple | Stable unique identifier across rebuilds for Features |

## Host Requirements

| Property | Type | Description |
|----------|------|-------------|
| `hostRequirements.cpus` 🏷️ | integer | Minimum required CPU cores |
| `hostRequirements.memory` 🏷️ | string | Minimum RAM with suffix: `tb`, `gb`, `mb`, `kb` |
| `hostRequirements.storage` 🏷️ | string | Minimum storage with suffix |
| `hostRequirements.gpu` 🏷️ | boolean/string/object | GPU requirement; `"optional"` when available |
