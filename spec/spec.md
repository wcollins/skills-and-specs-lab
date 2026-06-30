# Functional Spec: Skills & Specs Lab

## Purpose

Deliver the first half of *Engineering Agentic Network Operations* as a
standalone, hands-on lab that teaches network engineers to move from raw MCP
tools to structured skills (Module 1), and to constrain agent behavior with
behavioral specs (Module 2).

## Users

- **Student:** an intermediate network engineer comfortable with the CLI and
  basic MCP concepts. Owns a laptop (macOS, Linux, or Windows + WSL2) that meets
  the hardware floor.
- **Instructor:** runs the live session, maintains the repo, reviews showcase
  contributions.
- **Second-half instructor:** consumes the midpoint state contract.

## Functional requirements

### FR1: One-command verifiable setup
- `verify-setup.sh` reports green when Docker, Containerlab, Gridctl, the SR
  Linux image, and an MCP client are all present at the required versions.
- A motivated stranger completes `setup/` in under 30 minutes.

### FR2: Deterministic lab fabric
- `deploy.sh` brings up a 2-spine, 2-leaf SR Linux fabric to a known-good state.
- `smoke-test.sh` confirms interfaces are up and eBGP is established.
- `reset.sh` returns to known-good in under two minutes.
- `destroy.sh` removes all fabric containers.

### FR3: Agent stack
- `gridctl apply stack.yaml` brings up the MCP gateway with the clab MCP server
  filtered to read-only tools and the curated skill registry loaded.
- `gridctl link` connects the student's MCP client through one endpoint.

### FR4: Module 1 content
- A side-by-side comparison of a raw MCP tool and the same capability as a skill.
- Two buildable skills: device state query (structured output) and change
  validation (pre/post comparison).
- A chaining exercise composing both skills against the fabric.
- An instructor demo of the `contributing` skill running fork-and-PR end to end.

### FR5: Module 2 content
- A plain-language change request and a behavioral spec template.
- A deliberately under-specified spec (`spec-v1`) that drifts repeatably.
- A tightened spec (`spec-v2`) that removes the drift.
- The loop: write spec, run agent, observe drift, tighten, rerun.

### FR6: Midpoint contract
- A written definition of the exact state each student holds at the midpoint.
- `checkpoint.sh` validates that state and restores it from solutions if broken.

### FR7: Post-workshop contribution
- `CONTRIBUTING.md` documents the fork-and-PR flow, PR template, safe-content
  rules, and best-effort review expectations.
- The `contributing` skill scaffolds a contribution and walks the flow,
  including PAT creation as the first checkpoint.

## Non-functional requirements

- **Determinism:** the drift exercise reproduces across 5+ runs and two model
  versions (Constitution, Article IV).
- **Portability:** no artifact hard-depends on Claude Code (Article III).
- **Recoverability:** no unrecoverable student states (Article I).
- **Footprint:** runs on the stated hardware floor (set after Phase 7
  measurement).

## Out of scope

- Part 2 content (agentic loops, OpenClaw, NetClaw). Only the prerequisites their
  setup shares are folded into `setup/`.
- Live PR exercise during the session (replaced by the async contribution flow).
- GitHub PAT or MCP setup in pre-work (moved to the post-workshop flow).

## Acceptance

The lab is done when a beta tester who attended neither workshop can, from the
`setup/` guides alone, reach a green `verify-setup.sh`, complete both modules,
and finish with a green `checkpoint.sh`.
