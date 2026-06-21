#!/usr/bin/env bash
# =============================================================================
# Skills & Specs Lab - Setup Verification
# =============================================================================
# Verifies prerequisites for Part 1 of "Engineering Agentic Network Operations".
# Run from the repo root: ./scripts/verify-setup.sh
#
# This script grows one section per build phase. Sections are additive so it
# doubles as the instructor's dry-run tool.
# =============================================================================
set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; NC='\033[0m'
PASS=0; FAIL=0; WARN=0

SRL_IMAGE="ghcr.io/nokia/srlinux:${SRL_VERSION:-25.10.2}"
GRIDCTL_MIN="0.1.0"

header() { echo ""; echo -e "${BLUE}━━━ $1 ━━━${NC}"; }
ok()   { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS+1)); }
bad()  { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL+1)); }
warn() { echo -e "  ${YELLOW}!${NC} $1"; WARN=$((WARN+1)); }

vge() { [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]; }

# --- Phase 1: host tooling -----------------------------------------------------
check_docker() {
  header "Docker"
  if command -v docker >/dev/null 2>&1; then
    ok "docker installed ($(docker --version | grep -oE '[0-9]+\.[0-9]+' | head -1))"
    if docker ps >/dev/null 2>&1; then ok "docker daemon running"
    else bad "docker daemon not running"; fi
  else bad "docker not installed (see setup/01-docker-containerlab.md)"; fi
}

check_containerlab() {
  header "Containerlab"
  if command -v containerlab >/dev/null 2>&1; then
    ok "containerlab installed ($(containerlab version 2>/dev/null | grep -oiE 'version:?[ ]*[0-9.]+' | grep -oE '[0-9.]+' | head -1))"
  else
    if [ "$(uname -s)" = "Darwin" ]; then
      warn "containerlab not on PATH. On macOS it runs inside your OrbStack Linux VM; run this script there (setup/01-docker-containerlab.md)."
    else
      bad "containerlab not installed (see setup/01-docker-containerlab.md)"
    fi
  fi
}

check_srl_image() {
  header "SR Linux image"
  if ! docker ps >/dev/null 2>&1; then warn "cannot check image, docker unavailable"; return; fi
  if docker image inspect "$SRL_IMAGE" >/dev/null 2>&1; then
    ok "image present: $SRL_IMAGE"
  elif docker images | grep -q "nokia/srlinux"; then
    warn "an srlinux image is present but not the pinned tag ($SRL_IMAGE)"
  else
    bad "SR Linux image not pulled (see setup/02-srlinux-image.md): docker pull $SRL_IMAGE"
  fi
}

# --- Phase 3: agent stack ------------------------------------------------------
check_gridctl() {
  header "Gridctl"
  if command -v gridctl >/dev/null 2>&1; then
    GV="$(gridctl version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
    if [ -n "$GV" ] && vge "$GV" "$GRIDCTL_MIN"; then ok "gridctl $GV (>= $GRIDCTL_MIN)"
    else warn "gridctl present but version unconfirmed (saw '${GV:-?}', want >= $GRIDCTL_MIN)"; fi
  else bad "gridctl not installed (see setup/04-gridctl.md)"; fi
}

check_client() {
  header "MCP client"
  if command -v claude >/dev/null 2>&1; then
    ok "Claude Code installed ($(claude --version 2>/dev/null | head -1))"
  else
    warn "Claude Code not found. Any MCP client works via 'gridctl link'; Claude Code is the worked example (setup/04-gridctl.md)."
  fi
}

check_git() {
  header "git"
  if command -v git >/dev/null 2>&1; then ok "git installed ($(git --version | grep -oE '[0-9.]+' | head -1))"
  else warn "git not installed (needed only for the post-workshop contribution flow)"; fi
}

# --- Phase 2: fabric health (only if deployed) ---------------------------------
check_fabric() {
  header "Lab fabric (optional, only if deployed)"
  if ! docker ps >/dev/null 2>&1; then warn "docker unavailable, skipping fabric check"; return; fi
  local running
  running="$(docker ps --format '{{.Names}}' | grep -c '^clab-skills-specs-lab-' || true)"
  if [ "${running:-0}" -eq 4 ]; then
    ok "4/4 fabric nodes running (run ./scripts/smoke-test.sh for BGP health)"
  elif [ "${running:-0}" -gt 0 ]; then
    warn "${running}/4 fabric nodes running (run ./scripts/deploy.sh)"
  else
    warn "fabric not deployed yet (./scripts/deploy.sh) - not required for setup verification"
  fi
}

echo "========================================"
echo "  Skills & Specs Lab - Setup Verification"
echo "========================================"
check_docker
check_containerlab
check_srl_image
check_gridctl
check_client
check_git
check_fabric

header "Summary"
echo -e "  ${GREEN}Passed:${NC} $PASS   ${RED}Failed:${NC} $FAIL   ${YELLOW}Warnings:${NC} $WARN"
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}All required checks passed. You are ready for the workshop.${NC}"
  exit 0
else
  echo -e "${RED}$FAIL required check(s) failed. See the setup/ guides.${NC}"
  exit 1
fi
