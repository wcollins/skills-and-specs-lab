#!/usr/bin/env bash
# Tear down the Skills & Specs Lab SR Linux fabric.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(dirname "$SCRIPT_DIR")/lab-environment"
TOPO="topology.clab.yml"

YELLOW='\033[0;33m'; GREEN='\033[0;32m'; NC='\033[0m'

CLAB="containerlab"
if [ "$(id -u)" -ne 0 ] && ! containerlab version >/dev/null 2>&1; then
  CLAB="sudo containerlab"
fi

echo -e "${YELLOW}Destroying fabric ...${NC}"
cd "$LAB_DIR"
$CLAB destroy -t "$TOPO" --cleanup
echo -e "${GREEN}Fabric destroyed.${NC}"
