#!/usr/bin/env bash
# Install a Claude Code dev container template into a project repository.
#
# USAGE:
#   scripts/install.sh [target-dir] [--force] [--dry-run] [--help]
#
# ARGUMENTS:
#   target-dir   Path to the project root (default: current directory)
#
# OPTIONS:
#   --force      Overwrite an existing .devcontainer/ without prompting
#   --dry-run    Show what would be done without writing any files
#   --help       Show this help

set -euo pipefail

REGISTRY="ghcr.io/joeblackwaslike"
TEMPLATES=(
    "claude-code|Use the pre-built image directly (recommended for most projects)"
    "claude-code-extend|Extend the image with a Dockerfile for project-specific tools"
)

TARGET_DIR=""
FORCE=0
DRY_RUN=0

# ── Argument parsing ──────────────────────────────────────────────────────────

usage() {
    cat <<EOF
Usage: scripts/install.sh [target-dir] [options]

Install a Claude Code dev container template into a project.

Arguments:
  target-dir    Project root to install into (default: current directory)

Options:
  --force       Overwrite an existing .devcontainer/ without prompting
  --dry-run     Print what would happen without writing anything
  --help        Show this help

Templates available:
  claude-code          Use the pre-built image directly
  claude-code-extend   Extend with a project-specific Dockerfile

After running, open VS Code and choose "Dev Containers: Reopen in Container".
Edit .devcontainer/custom-setup.sh for project-specific setup.
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h) usage ;;
        --force)   FORCE=1;   shift ;;
        --dry-run) DRY_RUN=1; shift ;;
        -*)        echo "Unknown option: $1" >&2; usage ;;
        *)         TARGET_DIR="$1"; shift ;;
    esac
done

TARGET_DIR="$(cd "${TARGET_DIR:-.}" && pwd)"

# ── Preflight ─────────────────────────────────────────────────────────────────

if [ ! -d "$TARGET_DIR/.git" ]; then
    echo "error: $TARGET_DIR is not a git repository root" >&2
    exit 1
fi

if ! command -v devcontainer >/dev/null 2>&1; then
    echo "error: 'devcontainer' CLI not found" >&2
    echo "  Install with: npm install -g @devcontainers/cli" >&2
    exit 1
fi

DEFAULT_NAME="$(basename "$TARGET_DIR")"

# ── Prompt: template ──────────────────────────────────────────────────────────

echo ""
echo "Target: $TARGET_DIR"
echo ""
echo "Which template?"
echo ""

i=1
for entry in "${TEMPLATES[@]}"; do
    id="${entry%%|*}"
    desc="${entry##*|}"
    printf "  %d) %-26s %s\n" "$i" "$id" "$desc"
    (( i++ ))
done

echo ""
read -rp "Choice [1]: " template_idx
template_idx="${template_idx:-1}"

if ! [[ "$template_idx" =~ ^[0-9]+$ ]] || \
   [ "$template_idx" -lt 1 ] || [ "$template_idx" -gt "${#TEMPLATES[@]}" ]; then
    echo "error: invalid choice '$template_idx'" >&2
    exit 1
fi

SELECTED="${TEMPLATES[$((template_idx - 1))]}"
TEMPLATE_ID="${SELECTED%%|*}"
TEMPLATE_REF="$REGISTRY/$TEMPLATE_ID"

# ── Prompt: container name ────────────────────────────────────────────────────

echo ""
read -rp "Container name [$DEFAULT_NAME]: " CONTAINER_NAME
CONTAINER_NAME="${CONTAINER_NAME:-$DEFAULT_NAME}"

# ── Prompt: .gitignore ───────────────────────────────────────────────────────

GITIGNORE_PATH="$TARGET_DIR/.gitignore"
ADD_GITIGNORE=0
if [ -f "$GITIGNORE_PATH" ] && \
   ! grep -qx '\.devcontainer' "$GITIGNORE_PATH" 2>/dev/null && \
   ! grep -qx '\.devcontainer/' "$GITIGNORE_PATH" 2>/dev/null; then
    echo ""
    echo "The dev container config is maintained centrally in this repo."
    read -rp "Add .devcontainer/ to $TARGET_DIR/.gitignore? [y/N] " gi_ans
    [[ "${gi_ans,,}" == "y" ]] && ADD_GITIGNORE=1
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "  template : $TEMPLATE_ID"
echo "  target   : $TARGET_DIR"
echo "  name     : $CONTAINER_NAME"
[ "$ADD_GITIGNORE" = "1" ] && echo "  gitignore: will add .devcontainer/"
[ "$DRY_RUN" = "1" ]       && echo "  mode     : DRY RUN (no files written)"
echo ""

if [ "$DRY_RUN" = "1" ]; then
    echo "[dry] would run: devcontainer templates apply -t $TEMPLATE_REF -a '{\"containerName\": \"$CONTAINER_NAME\"}' -w $TARGET_DIR"
    exit 0
fi

# ── Handle existing .devcontainer/ ───────────────────────────────────────────

DEST="$TARGET_DIR/.devcontainer"
if [ -d "$DEST" ]; then
    if [ "$FORCE" = "0" ]; then
        echo "error: $DEST already exists — use --force to overwrite" >&2
        exit 1
    fi
    rm -rf "$DEST"
fi

# ── Apply template ────────────────────────────────────────────────────────────

devcontainer templates apply \
    -t "$TEMPLATE_REF" \
    -a "{\"containerName\": \"$CONTAINER_NAME\"}" \
    -w "$TARGET_DIR"

# ── Post-apply ────────────────────────────────────────────────────────────────

if [ "$ADD_GITIGNORE" = "1" ]; then
    echo ".devcontainer/" >> "$GITIGNORE_PATH"
    echo "  added .devcontainer/ to .gitignore"
fi

echo ""
echo "Done! Next steps:"
echo "  1.  cd $TARGET_DIR"
echo "  2.  code .   (open in VS Code)"
echo "  3.  'Dev Containers: Reopen in Container'"
echo "  4.  Edit .devcontainer/custom-setup.sh for project-specific setup"
