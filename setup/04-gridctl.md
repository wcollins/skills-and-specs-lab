# 04 - Gridctl

Gridctl is the MCP gateway that sits between your client and the workshop tools.
It also carries a skill registry. You install it, apply the workshop stack, load
the core skills, and link your client. Building the Containerlab MCP server is
optional and covered at the end.

On macOS, run everything in this guide inside the OrbStack VM (`orb -m clab`), the
same host as Docker and Containerlab. On Linux and WSL2, run it directly.

## Install Gridctl

1. Install the binary. It lands at `~/.local/bin/gridctl`.

   ```bash
   curl -fsSL https://raw.githubusercontent.com/gridctl/gridctl/main/install.sh | sh
   ```

2. Make sure `~/.local/bin` is on your `PATH`. If `gridctl version` fails, add it:

   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

   Add that line to your shell profile so it persists.

## Apply the stack and load skills

Run these from the repo root.

1. Validate the stack spec before applying.

   ```bash
   gridctl validate stack.yaml
   ```

2. Apply it. This brings up the gateway and its MCP servers.

   ```bash
   gridctl apply stack.yaml
   ```

   The gateway listens on `http://localhost:8180`. That URL is the web UI, and
   the MCP SSE endpoint is `http://localhost:8180/sse`.

3. Load the curated core skills into your local registry. They live at
   `~/.gridctl/registry/skills/` and Gridctl serves the active ones as MCP
   prompts.

   ```bash
   ./scripts/load-skills.sh
   ```

If a skill needs a secret later, store it in the Gridctl vault rather than in a
file, for example `gridctl var set <KEY>`.

## Link your client

Connect your MCP client to the gateway. Claude Code is the worked example:

```bash
gridctl link claude-code
```

To link every detected client at once, use `gridctl link --all`. Gridctl
supports Claude Desktop, Claude Code, Cursor, VS Code, OpenCode, and others.

## Verify this step

```bash
gridctl version
gridctl skill list
```

The first prints a version. The second lists the core skills you just loaded.
Open `http://localhost:8180` in a browser to see the gateway web UI, and confirm
your client now lists the gateway's MCP tools and skills.

## Optional: build the Containerlab MCP server (advanced)

This is optional. You can complete both modules without it. The core skills query
devices directly with `docker exec ... sr_cli`. The Containerlab MCP server
(FloSch62/clab-mcp-server) adds live topology awareness and is the demo for
least-privilege tool filtering: in `stack.yaml` it is filtered to read-only tools
(`authenticate`, `listLabs`, `inspectLab`), so deploy and destroy never reach the
model.

Be aware of what it requires before you start: a Go toolchain to compile it (no
published image), plus a running Containerlab API server (hellt/clab-api) for it
to talk to. If that is more than you want right now, skip it and continue to
guide 05.

To set it up:

1. Build the server binary.

   ```bash
   git clone https://github.com/FloSch62/clab-mcp-server
   cd clab-mcp-server
   go build -o clab-mcp-server main.go
   ```

2. Put the binary on `PATH`, or point Gridctl at it with an absolute path:

   ```bash
   export CLAB_MCP_BIN="$(pwd)/clab-mcp-server"
   ```

3. Run a Containerlab API server (hellt/clab-api) reachable at `API_SERVER_URL`
   (default `http://localhost:8080`) and set `API_USERNAME` and `API_PASSWORD`.
   The server uses stdio transport and will fail to list labs without this API
   server running.

4. Re-apply the stack so Gridctl picks up the binary and environment:

   ```bash
   gridctl apply stack.yaml
   ```

## Troubleshooting

- `gridctl: command not found` after install: `~/.local/bin` is not on your
  `PATH`. Add it (see step 2 above) and re-open your shell.
- `gridctl link` finds no client: install and authenticate the client first
  (guide 03), then re-run. On macOS, the client must be installed inside the
  same OrbStack VM as Gridctl so the two share a host.
