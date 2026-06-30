# Midpoint State Contract

Shared with the second-half instructor for review.

Part 1 ends at an instructor boundary. This document defines exactly what every
student possesses when my half ends and the state each artifact is in, so the
handoff is deterministic regardless of how any individual student's labs went.
`scripts/checkpoint.sh` enforces this contract and restores it from the repo
solutions if a student's state is broken.

## What every student has at the midpoint

| Artifact | State | How it got there | Validated by |
|----------|-------|------------------|--------------|
| SR Linux fabric | Deployed, converged (4 nodes, all interfaces up, all eBGP established) | `./scripts/deploy.sh` | `smoke-test.sh` |
| Gridctl stack | Running; gateway on `:8180`; clab server filtered to read-only tools | `gridctl apply stack.yaml` | `gridctl status` |
| `device-state-query` skill | In the registry | Built in Lab 1b (or restored from solutions) | registry file present |
| `change-validation` skill | In the registry | Built in Lab 1b (or restored from solutions) | registry file present |
| One iterated spec | v1 -> v2 understood; v2 available | Lab 2 | `spec-v2-tight.md` present |
| MCP client | Linked to the gateway | `gridctl link` | client sees skills as prompts |

## What "green" means

A student is green at the midpoint when `./scripts/checkpoint.sh` exits 0:

1. Fabric deployed and converged.
2. Gridctl stack running.
3. Both Module 1 skills present in the registry.
4. The Module 2 tightened spec available.

## Restoring a broken state

Any student who is not green runs:

```bash
./scripts/checkpoint.sh --restore
```

This resets the fabric to known-good, reloads the curated skills, copies the two
Module 1 solution skills into the registry, reloads the stack, and re-validates.
A student whose Lab 1 or Lab 2 went badly still crosses the midpoint green. That
is the point: the checkpoint caps liability so nobody is lost for the rest of the
day because of something that happened in my half.

## For the second-half instructor

Whether your content consumes these artifacts (the running fabric, the two
skills, the Gridctl stack) or resets to your own clean baseline is your call. My
commitment is only that the midpoint is deterministic either way:

- If you build on the fabric, `clab-skills-specs-lab-{spine1,spine2,leaf1,leaf2}`
  are up with the addressing in [`../AGENTS.md`](../AGENTS.md), creds
  `admin` / `admin`.
- If you reset, `./scripts/destroy.sh` cleanly removes the fabric and
  `gridctl destroy stack.yaml` removes the stack.

Please tell me during Phase 6 what prerequisites your modules add (for example
OpenClaw or NetClaw installs) so they fold into the same `setup/` flow and verify
script rather than becoming a second setup ask for students.
