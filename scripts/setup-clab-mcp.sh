#!/usr/bin/env bash
# =============================================================================
# Skills & Specs Lab - Turnkey clab MCP server setup
# =============================================================================
# The clab MCP server is OPTIONAL: the core skills query devices directly with
# `docker exec ... sr_cli`, and Lab 1a has a non-MCP fallback. This server adds
# live topology awareness and is the demo for least-privilege tool filtering
# (read-only allow-list in stack.yaml). It is normally a manual slog: install Go,
# compile FloSch62/clab-mcp-server, stand up a clab-api server. This script makes
# opting in a single command.
#
# What it does, idempotently and safe to re-run:
#   1. Preflight (docker, containerlab, git, gridctl) + detect OS/arch.
#   2. Install a Go toolchain into ~/.local/go if one is missing or too old.
#   3. Build clab-mcp-server and install it to ~/.local/bin.
#   4. Stand up the clab-api server as a container on :8080 and ensure an auth
#      user exists.
#   5. Write a sourceable env file and re-apply the gridctl stack.
#
# On macOS, run this inside the OrbStack Linux VM (`orb -m clab`), the same host
# as Docker and Containerlab. See setup/04-gridctl.md.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; NC='\033[0m'
header() { echo ""; echo -e "${BLUE}━━━ $1 ━━━${NC}"; }
ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }
die()  { echo -e "  ${RED}✗${NC} $1" >&2; exit 1; }

# --- Tunables (match stack.yaml defaults) -------------------------------------
GO_VERSION="1.23.4"                     # installed only if no recent Go is found
GO_MIN="1.22.0"                         # minimum acceptable existing toolchain
GO_ROOT="$HOME/.local/go"
LOCAL_BIN="$HOME/.local/bin"
SRC_DIR="$HOME/.local/src/clab-mcp-server"
MCP_REPO="https://github.com/FloSch62/clab-mcp-server"
GRIDCTL_HOME="${GRIDCTL_HOME:-$HOME/.gridctl}"
ENV_FILE="$GRIDCTL_HOME/clab-mcp.env"

API_PORT="8080"                         # repo standardizes on 8080 (upstream default is 8090)
CLAB_API_URL="http://localhost:${API_PORT}"
CLAB_API_USER="${CLAB_API_USER:-admin}"
CLAB_API_PASS="${CLAB_API_PASS:-password}"
API_SUPERUSER_GROUP="clab_admins"       # clab-api default superuser group
API_CONTAINER="clab-api-server"

vge() { [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]; }

# --- 1. Preflight -------------------------------------------------------------
header "Preflight"
for tool in docker containerlab git gridctl; do
  if command -v "$tool" >/dev/null 2>&1; then
    ok "$tool found"
  else
    case "$tool" in
      docker|containerlab) die "$tool not found (see setup/01-docker-containerlab.md). On macOS run this inside the OrbStack VM." ;;
      gridctl)             die "$tool not found (see setup/04-gridctl.md)." ;;
      git)                 die "$tool not found. Install git, then re-run." ;;
    esac
  fi
done
docker ps >/dev/null 2>&1 || die "docker daemon not running. Start Docker and re-run."

case "$(uname -s)" in
  Linux)  GOOS="linux" ;;
  Darwin) GOOS="darwin" ;;
  *)      die "unsupported OS '$(uname -s)'. This script targets Linux and macOS." ;;
esac
case "$(uname -m)" in
  x86_64|amd64)   GOARCH="amd64" ;;
  aarch64|arm64)  GOARCH="arm64" ;;
  *)              die "unsupported arch '$(uname -m)'." ;;
esac
ok "platform: ${GOOS}/${GOARCH}"

mkdir -p "$LOCAL_BIN"

# --- 2. Ensure Go -------------------------------------------------------------
header "Go toolchain"
need_go=1
if command -v go >/dev/null 2>&1; then
  cur="$(go version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)"
  if [ -n "$cur" ] && vge "$cur" "$GO_MIN"; then
    ok "go $cur already installed (>= $GO_MIN)"
    need_go=0
  else
    warn "go ${cur:-?} is older than $GO_MIN; installing $GO_VERSION into $GO_ROOT"
  fi
else
  warn "go not found; installing $GO_VERSION into $GO_ROOT"
fi

if [ "$need_go" -eq 1 ]; then
  tarball="go${GO_VERSION}.${GOOS}-${GOARCH}.tar.gz"
  url="https://go.dev/dl/${tarball}"
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  echo "  downloading $url ..."
  curl -fsSL "$url" -o "$tmp/$tarball" || die "failed to download Go from $url"
  rm -rf "$GO_ROOT"
  mkdir -p "$(dirname "$GO_ROOT")"
  tar -C "$tmp" -xzf "$tmp/$tarball" || die "failed to extract Go tarball"
  mv "$tmp/go" "$GO_ROOT"
  ok "installed Go $GO_VERSION at $GO_ROOT"
fi

# Make sure `go` is on PATH for the rest of this script.
if [ -x "$GO_ROOT/bin/go" ]; then
  export PATH="$GO_ROOT/bin:$PATH"
fi
command -v go >/dev/null 2>&1 || die "go still not on PATH after install"

# --- 3. Build clab-mcp-server -------------------------------------------------
header "clab-mcp-server"
if [ -d "$SRC_DIR/.git" ]; then
  ok "source present at $SRC_DIR; pulling latest"
  git -C "$SRC_DIR" pull --ff-only --quiet || warn "git pull failed; building current checkout"
else
  mkdir -p "$(dirname "$SRC_DIR")"
  git clone --quiet "$MCP_REPO" "$SRC_DIR" || die "failed to clone $MCP_REPO"
  ok "cloned $MCP_REPO"
fi

( cd "$SRC_DIR" && GOOS="$GOOS" GOARCH="$GOARCH" go build -o "$LOCAL_BIN/clab-mcp-server" main.go ) \
  || die "go build failed in $SRC_DIR"
CLAB_MCP_BIN="$LOCAL_BIN/clab-mcp-server"
ok "built $CLAB_MCP_BIN"

# --- 4. Stand up the clab-api server ------------------------------------------
header "clab-api server (:${API_PORT})"

# Auth is via Linux PAM users. Ensure a user in the superuser group exists so it
# can inspect the root-deployed fabric. Skips cleanly if the user already exists.
if [ "$GOOS" = "linux" ]; then
  if command -v useradd >/dev/null 2>&1; then
    sudo groupadd -f "$API_SUPERUSER_GROUP" || warn "could not ensure group $API_SUPERUSER_GROUP"
    if id "$CLAB_API_USER" >/dev/null 2>&1; then
      ok "user '$CLAB_API_USER' exists"
    else
      sudo useradd -m -s /bin/bash "$CLAB_API_USER" || die "failed to create user '$CLAB_API_USER'"
      ok "created user '$CLAB_API_USER'"
    fi
    echo "${CLAB_API_USER}:${CLAB_API_PASS}" | sudo chpasswd || warn "could not set password for '$CLAB_API_USER'"
    sudo usermod -aG "$API_SUPERUSER_GROUP" "$CLAB_API_USER" || warn "could not add '$CLAB_API_USER' to $API_SUPERUSER_GROUP"
    ok "'$CLAB_API_USER' is in $API_SUPERUSER_GROUP"
  else
    warn "useradd not available; ensure a PAM user '$CLAB_API_USER' in group '$API_SUPERUSER_GROUP' exists for auth"
  fi
else
  warn "non-Linux host: ensure a PAM user '$CLAB_API_USER' in group '$API_SUPERUSER_GROUP' exists for auth (run inside the OrbStack VM)"
fi

if docker ps --format '{{.Names}}' | grep -qx "$API_CONTAINER"; then
  # The PAM user/password were just (re)written above. useradd/chpasswd replace
  # /etc/passwd and /etc/shadow via atomic rename, which swaps the file's inode.
  # An already-running container bind-mounts those files and stays pinned to the
  # OLD inode, so it would never see the new user or the changed password -> auth
  # fails with 401 even though the creds are "correct". Restart it so the bind
  # mounts re-resolve to the current inodes. (A fresh start below is unaffected,
  # because it mounts the files only after the user already exists.)
  echo "  restarting clab-api server so it picks up the current PAM users ..."
  docker restart "$API_CONTAINER" >/dev/null \
    || warn "could not restart $API_CONTAINER; if auth fails run: docker restart $API_CONTAINER"
  ok "clab-api server restarted ($API_CONTAINER)"
else
  echo "  starting clab-api server on :${API_PORT} (plain HTTP, TLS disabled to match stack.yaml) ..."
  # Pin the port to 8080 and disable TLS so the endpoint is http:// as stack.yaml expects.
  sudo containerlab tools api-server start \
    --port "$API_PORT" \
    --tls-enable=false \
    --labs-dir "$REPO_ROOT/lab-environment" \
    || die "failed to start clab-api server. Try: sudo containerlab tools api-server start --port $API_PORT --tls-enable=false"
fi

# Wait for the endpoint to answer before continuing.
echo "  waiting for $CLAB_API_URL ..."
reachable=0
for _ in $(seq 1 30); do
  if curl -s -o /dev/null --max-time 2 "$CLAB_API_URL/" 2>/dev/null; then reachable=1; break; fi
  sleep 1
done
if [ "$reachable" -eq 1 ]; then
  ok "clab-api reachable at $CLAB_API_URL"
else
  warn "clab-api not answering yet at $CLAB_API_URL. Check 'docker logs $API_CONTAINER'; the stack will retry."
fi

# --- 5. Env file + re-apply the stack -----------------------------------------
header "Environment + stack"
mkdir -p "$GRIDCTL_HOME"
cat > "$ENV_FILE" <<EOF
# Skills & Specs Lab - clab MCP server environment.
# Written by scripts/setup-clab-mcp.sh. Source this in shells that run gridctl:
#   source $ENV_FILE
# and add that line to your shell profile so it persists.
export PATH="$GO_ROOT/bin:$LOCAL_BIN:\$PATH"
export CLAB_MCP_BIN="$CLAB_MCP_BIN"
export CLAB_API_URL="$CLAB_API_URL"
export CLAB_API_USER="$CLAB_API_USER"
export CLAB_API_PASS="$CLAB_API_PASS"
EOF
ok "wrote $ENV_FILE"

# Export for this process so gridctl resolves the ${...} placeholders in stack.yaml.
export CLAB_MCP_BIN CLAB_API_URL CLAB_API_USER CLAB_API_PASS

echo "  re-applying the gridctl stack ..."
if gridctl apply "$REPO_ROOT/stack.yaml"; then
  ok "stack applied"
else
  warn "gridctl apply reported an error; check 'gridctl status'"
fi

# --- Done ---------------------------------------------------------------------
header "Done"
echo "  The clab MCP server is set up. In every new shell that runs gridctl or your"
echo "  client, load the environment first:"
echo ""
echo -e "      ${GREEN}source $ENV_FILE${NC}"
echo ""
echo "  Then confirm health and the read-only filter:"
echo "      gridctl status                 # the 'clab' server should be healthy"
echo "      gridctl skill list"
echo ""
echo "  In your client, Lab 1a's raw-tool path now works:"
echo "      > Use the clab inspectLab tool to inspect the skills-specs-lab lab and show me the raw result."
