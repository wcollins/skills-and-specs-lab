#!/usr/bin/env bash
# Load the curated core skills into the local gridctl registry.
# gridctl serves every active SKILL.md under ~/.gridctl/registry/skills/ as an
# MCP prompt. Skills are NOT declared in stack.yaml; they live in the registry.
#
# The primary path is the git import:
#   gridctl skill add https://github.com/wcollins/skills-and-specs-lab --path skills
# which lets students re-sync later with `gridctl skill update`. This script is
# the deterministic offline fallback for when GitHub is unreachable.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
REGISTRY="${GRIDCTL_HOME:-$HOME/.gridctl}/registry/skills"

GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'

mkdir -p "$REGISTRY"
echo -e "${YELLOW}Loading core skills into ${REGISTRY} ...${NC}"

for dir in "$REPO_ROOT"/skills/*/; do
  [ -f "${dir}SKILL.md" ] || continue
  name="$(basename "$dir")"
  mkdir -p "$REGISTRY/$name"
  cp "${dir}SKILL.md" "$REGISTRY/$name/SKILL.md"
  echo -e "  ${GREEN}✓${NC} $name"
done

echo ""
echo "Loaded. Verify with: gridctl skill list"
echo "Skills marked 'state: active' surface immediately; activate drafts with:"
echo "  gridctl activate <name>"
