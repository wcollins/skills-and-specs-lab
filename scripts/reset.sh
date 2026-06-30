#!/usr/bin/env bash
# The unsung hero of a live workshop: return a wrecked environment to known-good.
# Destroys and redeploys the fabric, then smoke-tests it. Target: ~90 seconds.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLUE='\033[0;34m'; GREEN='\033[0;32m'; NC='\033[0m'

echo -e "${BLUE}Resetting the lab fabric to known-good ...${NC}"
"$SCRIPT_DIR/destroy.sh" || true
"$SCRIPT_DIR/deploy.sh"

echo -e "${BLUE}Waiting 30s for BGP to converge ...${NC}"
sleep 30

"$SCRIPT_DIR/smoke-test.sh"
echo -e "${GREEN}Reset complete. You are back to a known-good fabric.${NC}"
