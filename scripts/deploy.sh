#!/usr/bin/env bash
# Deploy the Skills & Specs Lab SR Linux fabric to a known-good state.
# Idempotent: re-running reconfigures in place.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(dirname "$SCRIPT_DIR")/lab-environment"
TOPO="topology.clab.yml"

GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'

# containerlab needs root for netns/veth operations unless running rootless.
CLAB="containerlab"
if [ "$(id -u)" -ne 0 ] && ! containerlab version >/dev/null 2>&1; then
  CLAB="sudo containerlab"
fi

if ! command -v containerlab >/dev/null 2>&1; then
  echo -e "${RED}containerlab not found.${NC} On macOS, run this inside your OrbStack"
  echo "Linux VM. See setup/01-docker-containerlab.md."
  exit 1
fi

echo -e "${YELLOW}Deploying fabric from ${LAB_DIR}/${TOPO} ...${NC}"
cd "$LAB_DIR"
$CLAB deploy -t "$TOPO" --reconfigure

echo ""
echo -e "${GREEN}Fabric deployed.${NC} Nodes: spine1, spine2, leaf1, leaf2."
echo "Give BGP ~30s to converge, then run: ./scripts/smoke-test.sh"
