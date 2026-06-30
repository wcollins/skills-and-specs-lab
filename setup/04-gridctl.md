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

## Apply the stack and import skills

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

3. Import the curated core skills into your local registry, straight from the
   workshop repo. They land in `~/.gridctl/registry/skills/`, and Gridctl serves
   the active ones as MCP prompts. Because each imported skill keeps a link to
   its source, you can pull later changes with `gridctl skill update` instead of
   re-copying anything.

   ```bash
   gridctl skill add https://github.com/wcollins/skills-and-specs-lab --path skills
   ```

   No network, or want the deterministic offline path? Use the bundled copy
   instead: `./scripts/load-skills.sh`.

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

The first prints a version. The second lists the core skills you just imported.
Open `http://localhost:8180` in a browser to see the gateway web UI, and confirm
your client now lists the gateway's MCP tools and skills.

## Optional: set up the Containerlab MCP server (turnkey)

This is optional. You can complete both modules without it — the core skills query
devices directly with `docker exec ... sr_cli`, and Lab 1a has a non-MCP fallback.
The Containerlab MCP server (FloSch62/clab-mcp-server) adds live topology awareness
and is the demo for least-privilege tool filtering: in `stack.yaml` it is filtered
to read-only tools (`authenticate`, `listLabs`, `inspectLab`), so deploy and destroy
never reach the model.

It used to be a manual slog (compile a Go binary, stand up a separate Containerlab
API server). Now it is one command:

```bash
./scripts/setup-clab-mcp.sh
```

The script installs a Go toolchain if you do not have one, builds the
`clab-mcp-server` binary into `~/.local/bin`, starts a Containerlab API server on
`:8080`, writes an env file at `~/.gridctl/clab-mcp.env`, and re-applies the stack.
It is idempotent — safe to re-run. It uses `sudo` for the API server container and
the auth user, so you will be prompted for your password.

When it finishes, load the env file in shells that run Gridctl (and add the line to
your shell profile so it persists), then confirm health:

```bash
source ~/.gridctl/clab-mcp.env
gridctl status        # the 'clab' server should be healthy
```

Prefer to skip it for now? Continue to guide 05 — nothing downstream is blocked.

## Troubleshooting

- `gridctl: command not found` after install: `~/.local/bin` is not on your
  `PATH`. Add it (see step 2 above) and re-open your shell.
- `gridctl link` finds no client: install and authenticate the client first
  (guide 03), then re-run. On macOS, the client must be installed inside the
  same OrbStack VM as Gridctl so the two share a host.
