#!/usr/bin/env bash
# Midpoint state contract validator (and restorer).
#
# At the end of Part 1 every student must hold the same known, verifiable state
# regardless of how their individual labs went. This script proves it, and with
# --restore rebuilds it from the solutions in this repo. See
# docs/midpoint-contract.md for the contract this enforces.
#
#   ./scripts/checkpoint.sh            # validate only
#   ./scripts/checkpoint.sh --restore  # rebuild the midpoint state, then validate
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
REGISTRY="${GRIDCTL_HOME:-$HOME/.gridctl}/registry/skills"
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; NC='\033[0m'
FAIL=0
RESTORE=0
[ "${1:-}" = "--restore" ] && RESTORE=1

restore_state() {
  echo -e "${YELLOW}Restoring midpoint state from solutions ...${NC}"
  # 1. Fabric back to known-good
  "$SCRIPT_DIR/reset.sh" || true
  # 2. Core + solution skills into the registry. Restore deliberately uses the
  #    offline copy (not `gridctl skill add`) so the escape hatch never depends
  #    on GitHub being reachable mid-workshop.
  "$SCRIPT_DIR/load-skills.sh"
  for s in device-state-query change-validation; do
    src="$REPO_ROOT/lab-01/solutions/$s/SKILL.md"
    [ -f "$src" ] || continue
    mkdir -p "$REGISTRY/$s"
    cp "$src" "$REGISTRY/$s/SKILL.md"
    echo -e "  ${GREEN}✓${NC} restored skill: $s"
  done
  # 3. Activate the restored skills. The solution SKILL.md files ship as
  #    'state: draft', and Gridctl only serves active skills as prompts. Without
  #    this the files exist but the client never sees them at the Part 2 handoff.
  gridctl activate device-state-query change-validation >/dev/null 2>&1 || true
  # 4. Reload the running stack so the registry change is served
  gridctl reload skills-specs-lab >/dev/null 2>&1 || true
  echo ""
}

[ "$RESTORE" -eq 1 ] && restore_state

echo -e "${BLUE}Validating midpoint state contract ...${NC}"

# Contract item 1: fabric healthy
if "$SCRIPT_DIR/smoke-test.sh" >/dev/null 2>&1; then
  echo -e "  ${GREEN}✓${NC} fabric deployed and converged"
else
  echo -e "  ${RED}✗${NC} fabric not healthy (./scripts/checkpoint.sh --restore)"; FAIL=1
fi

# Contract item 2: gridctl stack running
if gridctl status 2>/dev/null | grep -qi 'skills-specs-lab'; then
  echo -e "  ${GREEN}✓${NC} gridctl stack running"
else
  echo -e "  ${RED}✗${NC} gridctl stack not running (gridctl apply stack.yaml)"; FAIL=1
fi

# Contract item 3: the two Module 1 skills exist in the registry
for s in device-state-query change-validation; do
  if [ -f "$REGISTRY/$s/SKILL.md" ]; then
    echo -e "  ${GREEN}✓${NC} skill present: $s"
  else
    echo -e "  ${RED}✗${NC} skill missing: $s (./scripts/checkpoint.sh --restore)"; FAIL=1
  fi
done

# Contract item 4: a Module 2 spec has been iterated (v2 present or authored)
if [ -f "$REPO_ROOT/lab-02/solutions/spec-v2-tight.md" ]; then
  echo -e "  ${GREEN}✓${NC} Module 2 spec available (tightened v2 in solutions)"
else
  echo -e "  ${YELLOW}!${NC} Module 2 tightened spec not found"
fi

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}Midpoint state is GREEN. You are ready to hand off to Part 2.${NC}"
  exit 0
else
  echo -e "${RED}Midpoint state is not green.${NC} Run: ./scripts/checkpoint.sh --restore"
  exit 1
fi
