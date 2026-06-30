#!/usr/bin/env bash
# Confirm the fabric converged: fabric interfaces oper-up and eBGP established.
# Exit 0 only when every node passes. Reused conceptually by the Module 1
# change-validation skill (snapshot the same state before and after a change).
set -euo pipefail

PREFIX="clab-skills-specs-lab"
NODES=(spine1 spine2 leaf1 leaf2)
EXPECTED_PEERS=2   # each node peers with two neighbors

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; NC='\033[0m'
FAIL=0

srl() { docker exec "${PREFIX}-$1" sr_cli "$2" 2>/dev/null; }

echo -e "${BLUE}Smoke test: ${PREFIX} fabric${NC}"

for node in "${NODES[@]}"; do
  echo ""
  echo -e "${BLUE}── ${node} ──${NC}"

  if ! docker ps --format '{{.Names}}' | grep -q "${PREFIX}-${node}"; then
    echo -e "  ${RED}✗${NC} container ${PREFIX}-${node} not running"
    FAIL=1
    continue
  fi

  # Fabric interfaces up
  iface_out="$(srl "$node" 'show interface ethernet-1/{1,2} brief' || true)"
  up_count="$(printf '%s\n' "$iface_out" | grep -ciE '\bup\b' || true)"
  if [ "${up_count:-0}" -ge 2 ]; then
    echo -e "  ${GREEN}✓${NC} fabric interfaces up"
  else
    echo -e "  ${RED}✗${NC} fabric interfaces not all up (matched ${up_count:-0})"
    FAIL=1
  fi

  # BGP established
  bgp_out="$(srl "$node" 'show network-instance default protocols bgp neighbor' || true)"
  est_count="$(printf '%s\n' "$bgp_out" | grep -ci 'established' || true)"
  if [ "${est_count:-0}" -ge "$EXPECTED_PEERS" ]; then
    echo -e "  ${GREEN}✓${NC} BGP established (${est_count}/${EXPECTED_PEERS} peers)"
  else
    echo -e "  ${YELLOW}!${NC} BGP not fully established (${est_count}/${EXPECTED_PEERS}); may still be converging"
    FAIL=1
  fi
done

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}Fabric healthy: all interfaces up, all BGP sessions established.${NC}"
  exit 0
else
  echo -e "${RED}Fabric not fully converged.${NC} Wait 30s and re-run, or ./scripts/reset.sh"
  exit 1
fi
