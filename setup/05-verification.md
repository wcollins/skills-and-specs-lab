# 05 - Verification

One script confirms your whole setup. Run it last, read the summary, and fix
anything it flags before the workshop.

On macOS, run it inside the OrbStack VM (`orb -m clab`), because that is where
Containerlab lives. Running it on macOS directly will report Containerlab as not
found.

1. From the repo root, run the verifier.

   ```bash
   ./scripts/verify-setup.sh
   ```

## What it checks

The script checks, in order:

- Docker (installed and the daemon running).
- Containerlab (installed; on macOS it warns if you ran the script outside the
  VM).
- The SR Linux image (the pinned `ghcr.io/nokia/srlinux:25.10.2` tag).
- Gridctl (installed and a recent enough version).
- Your MCP client (Claude Code is detected by name; any client is fine).
- git (used only for the post-workshop contribution flow).
- Fabric health (optional; only reports if the four nodes are already deployed).

## Reading the results

Each line is one of three states:

- A green check is a pass.
- A red cross is a required failure. The line names the guide that fixes it.
  These must be cleared.
- A yellow `!` is a warning, not a blocker. Examples: the fabric is not deployed
  yet (expected during setup), or your client is not Claude Code (any MCP client
  works).

The summary line counts passed, failed, and warnings. The script exits 0 when no
required check failed and prints "All required checks passed. You are ready for
the workshop." If any required check fails, it exits 1 and points you at the
relevant `setup/` guide.

You do not need to deploy the fabric to pass verification. Deploying happens in
the lab itself, with `./scripts/deploy.sh` (never run by an agent).

## Verify this step

A clean run ends with:

```
All required checks passed. You are ready for the workshop.
```

Warnings about the fabric not being deployed or about a non-Claude client are
expected and do not block you.

## Troubleshooting

- Containerlab shows a warning on macOS even though you installed it: you ran the
  script from the macOS prompt, not inside the VM. Enter the VM with `orb -m clab`
  and run `./scripts/verify-setup.sh` there.
- "docker daemon not running": start Docker (on macOS, make sure the OrbStack VM
  is up and you are inside it), then re-run. An "image not pulled" failure
  usually clears once Docker is reachable and you complete guide 02.
