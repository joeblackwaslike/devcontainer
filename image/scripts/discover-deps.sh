#!/usr/bin/env bash

# Automatically installs repo-specific dependencies on every container attach.
#
# Detection order (first match wins per language):
#   JS/TS : always pnpm (legacy npm/yarn/bun lockfiles are imported and flagged for migration)
#   Python: pyproject.toml (uv sync) → requirements.txt (uv pip install)
#   Rust  : Cargo.toml (cargo fetch)
#   Go    : go.mod (go mod download)
#   Ruby  : Gemfile (bundle install)
#   Hook  : .devcontainer/custom-setup.sh (project-specific overrides)
#
# Set DISCOVER_DEPS_SKIP=1 to bypass all detection (useful in CI or bare containers).
# See docs/discover-deps.md for per-project customization docs.

set -euo pipefail

if [ "${DISCOVER_DEPS_SKIP:-0}" = "1" ]; then
    echo "discover-deps: skipped (DISCOVER_DEPS_SKIP=1)"
    exit 0
fi

WORKSPACE="${WORKSPACE_FOLDER:-${WORKSPACE_DIR:-$(pwd)}}"
cd "$WORKSPACE"

echo "==> discover-deps: $WORKSPACE"

# ── JavaScript / TypeScript ───────────────────────────────────────────────────
if [ -f package.json ]; then
    if [ ! -f pnpm-lock.yaml ]; then
        echo "    note: no pnpm-lock.yaml -- run 'bunx spinup-ts update . --yes' to migrate to pnpm + Bun"
    fi
    echo "    pnpm install"
    pnpm install
fi

# ── Python ────────────────────────────────────────────────────────────────────
if [ -f pyproject.toml ] && command -v uv >/dev/null 2>&1; then
    echo "    uv sync"
    uv sync 2>/dev/null || true
elif [ -f requirements.txt ]; then
    echo "    uv pip install -r requirements.txt"
    uv pip install -r requirements.txt 2>/dev/null \
        || pip install -r requirements.txt
fi

# ── Rust ──────────────────────────────────────────────────────────────────────
if [ -f Cargo.toml ]; then
    echo "    cargo fetch"
    cargo fetch
fi

# ── Go ────────────────────────────────────────────────────────────────────────
if [ -f go.mod ]; then
    echo "    go mod download"
    go mod download
fi

# ── Ruby ──────────────────────────────────────────────────────────────────────
if [ -f Gemfile ] && command -v bundle >/dev/null 2>&1; then
    echo "    bundle install"
    bundle install
fi

# ── Per-repo hook ─────────────────────────────────────────────────────────────
if [ -f .devcontainer/custom-setup.sh ]; then
    echo "    running .devcontainer/custom-setup.sh"
    bash .devcontainer/custom-setup.sh
fi

echo "==> discover-deps: done"
