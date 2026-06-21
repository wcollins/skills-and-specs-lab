# 03 - API keys and client auth

The workshop drives an LLM client that speaks MCP. Claude Code is the worked
example throughout, but everything is portable to any MCP client because Gridctl
wires the client to the gateway for you (guide 04). This guide covers
authenticating your client.

You do not need a GitHub personal access token for the workshop itself. A token
is only used in the optional post-workshop contribution flow.

## Claude Code (worked example)

1. Install Claude Code with the native installer. It needs no Node.js and lands
   at `~/.local/bin/claude`.

   ```bash
   curl -fsSL https://claude.ai/install.sh | bash
   ```

   Make sure `~/.local/bin` is on your `PATH` (the same directory Gridctl uses in
   guide 04). If `claude --version` fails, add it and persist it in your profile:

   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

   > Prefer npm? `npm install -g @anthropic-ai/claude-code` also works, but it
   > needs Node.js 18+ installed first, which the Debian VM does not have out of
   > the box. The native installer above avoids that dependency.

2. Authenticate, using one of two options:

   - Subscription login: run `claude` and follow the browser login. This uses
     your Claude subscription and has no per-token cost.
   - Anthropic API key: set an environment variable. An Anthropic API key is
     billed per token of usage, so watch your spend.

     ```bash
     export ANTHROPIC_API_KEY="sk-ant-..."
     ```

     Add that line to your shell profile (for example `~/.bashrc` inside the
     OrbStack VM or WSL2) so it persists across sessions.

If you are on macOS, install and run Claude Code inside the OrbStack VM, the same
place Docker and Containerlab live, so the client and the fabric share one host.

## Portable path (any MCP client)

You are not tied to Claude Code. Gridctl can link Claude Desktop, Cursor, VS
Code, OpenCode, and others (guide 04). Install and authenticate your client of
choice per its own documentation (for example OpenCode or Cursor with your
preferred model provider), then let `gridctl link` connect it to the gateway.
The skills and specs in this workshop are client-agnostic.

## Verify this step

For Claude Code:

```bash
claude --version
```

This prints a version string. If you authenticated with an API key, also confirm
the variable is set:

```bash
test -n "$ANTHROPIC_API_KEY" && echo "API key set"
```

## Troubleshooting

- `claude: command not found` after the native installer: `~/.local/bin` is not
  on your `PATH`. Add it (`export PATH="$HOME/.local/bin:$PATH"`) and re-open your
  shell. (If you used the npm method instead, run `npm prefix -g` and add its
  `bin` subdirectory to `PATH`.)
- Auth prompts repeat or calls are rejected: confirm you picked one method.
  Subscription login and `ANTHROPIC_API_KEY` are alternatives; a stale or
  mistyped key will fail. Re-run `claude` to log in, or re-export a valid key.
