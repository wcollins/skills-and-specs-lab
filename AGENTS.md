# AGENTS.md

Guidance for AI coding agents (Claude Code and any MCP-aware client) working in
this repository.

## Project Overview

**Skills & Specs Lab** is the first half of the Packt workshop *Engineering
Agentic Network Operations*. It teaches network engineers to build reliable AI
agents using three layers: MCP tools, agent skills, and behavioral specs.

- **Module 1 (Tools to Skills):** wrap raw MCP tools in structured, composable
  skills, then chain them into a workflow against a live network fabric.
- **Module 2 (Spec-Driven Development):** write behavioral specs, observe where
  an agent drifts, and tighten the spec without changing agent code.

The lab fabric is a small spine-leaf topology of Nokia SR Linux nodes deployed
with [Containerlab](https://containerlab.dev). Agent tooling is wired together
with [Gridctl](https://github.com/gridctl/gridctl), an MCP gateway with a
built-in skill registry.

## Repository Layout

| Path | Purpose |
|------|---------|
| `spec/` | Spec-kit artifacts for the workshop itself (constitution, spec, plan). Dogfood material for Module 2. |
| `lab-environment/` | Containerlab topology and SR Linux startup configs. |
| `scripts/` | Lifecycle and validation scripts (deploy, destroy, reset, smoke-test, verify-setup, checkpoint). |
| `stack.yaml` | Gridctl stack: clab MCP server (read-only filtered) plus the skills registry. |
| `skills/` | Curated core skills loaded into every student's registry. |
| `showcase/` | Open, community-contributed skills and labs (review before importing). |
| `lab-01/` | Module 1 lab guide, checkpoints, and solution skills. |
| `lab-02/` | Module 2 lab guide, spec templates, and known-drifting / tight specs. |
| `setup/` | Numbered student setup guides. |
| `docs/` | FAQ, troubleshooting matrix, midpoint state contract. |
| `run.md` | Instructor runbook: build, test, and roll back every part. |

## Commands

### Environment lifecycle
```bash
./scripts/verify-setup.sh          # Check all prerequisites are present
./scripts/deploy.sh                # Deploy the SR Linux fabric (known-good state)
./scripts/smoke-test.sh            # Confirm fabric converged (interfaces + BGP up)
./scripts/reset.sh                 # Destroy and redeploy to known-good (~90s)
./scripts/destroy.sh               # Tear the fabric down
./scripts/checkpoint.sh            # Validate / restore the midpoint state contract
```

### Gridctl stack
```bash
gridctl validate stack.yaml        # Validate the stack spec
gridctl apply stack.yaml           # Bring up the MCP gateway + clab server
gridctl status                     # Show running servers and health
gridctl link claude-code           # Wire Claude Code to the gateway
gridctl destroy stack.yaml         # Tear the stack down
```

### Skills registry
```bash
gridctl skill add <repo-url> --path skills   # Import skills from a git repo (workshop: this repo)
gridctl skill update                         # Re-sync imported skills from their source repo
gridctl skill list                           # List skills (SOURCE column shows git origin or 'local')
gridctl activate <name>                      # Activate a draft skill
# Offline fallback: ./scripts/load-skills.sh copies skills/* into the registry
```

## Network Facts

```
        spine1 (AS65100)      spine2 (AS65100)
        10.0.0.1/32           10.0.0.2/32
            │   │                 │   │
       ┌────┘   └────┐       ┌────┘   └────┐
     leaf1         leaf2   leaf1         leaf2
   AS65101       AS65102
   10.0.0.101/32 10.0.0.102/32
```

- **Nodes:** `spine1`, `spine2`, `leaf1`, `leaf2` (Nokia SR Linux, kind
  `nokia_srlinux`, type `ixr-d2l`, image `ghcr.io/nokia/srlinux:25.10.2`).
- **Host note:** Containerlab needs Linux. On macOS run everything inside an
  OrbStack arm64 Debian Linux VM (see `setup/01-docker-containerlab.md`).
- **Management:** `172.20.20.0/24` (spine1 .11, spine2 .12, leaf1 .21, leaf2 .22).
- **Credentials:** `admin` / `admin` (set in each `configs/*.cli` startup-config;
  overrides the Containerlab SR Linux default of `admin` / `NokiaSrl1!`).
- **Underlay:** eBGP, spines share AS65100, each leaf has a unique AS.
- **P2P links:** `/30` subnets in `10.x.y.0/30` (spine side `.1`, leaf side `.2`).
- **Loopbacks:** `system0.0`, advertised into BGP.

## Conventions

- Skills follow the [agentskills.io](https://agentskills.io/specification)
  `SKILL.md` format: YAML frontmatter (`name`, `description`, optional `state`)
  plus a markdown body. Gridctl serves active skills as MCP prompts.
- Topology must never be deployed by an agent during a lab. `deploy.sh` is the
  only sanctioned path to a known-good fabric. The clab MCP server is filtered
  to read-only tools for exactly this reason (least privilege in config).
- Every lab guide ends each exercise with a visible checkpoint ("you should now
  see X").
- Scripts are POSIX-ish bash, `set -euo pipefail`, and safe to re-run
  (idempotent where possible).
