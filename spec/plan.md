# Build Plan: Skills & Specs Lab

How the repository was built, in dependency order. Each phase has a verifiable
output and feeds the next. This mirrors `WORKSHOP-PLAN.md` and is kept here so
the repo carries its own build history (Module 2 dogfood material).

## Phase 0: Spec the workshop (this directory)
Constitution, spec, plan written before any content. The spec is the contract
every later phase answers to.
**Output:** `spec/`, `AGENTS.md`.

## Phase 1: Scaffold and verification harness
Directory structure, README skeleton, and `verify-setup.sh` that grows one check
per phase.
**Output:** navigable repo; verify checks Docker, Containerlab, Gridctl, client.

## Phase 2: Lab environment
SR Linux topology, startup configs, `deploy.sh` / `destroy.sh` / `reset.sh`, and
`smoke-test.sh` confirming convergence.
**Output:** one-command deploy to known-good; verify checks image and fabric.

## Phase 3: Gridctl stack and registry seed
`stack.yaml` with the clab MCP server (read-only filtered) and the skill
registry. Seed three skills: a reference skill, `skills-creator`, `contributing`.
**Output:** `gridctl apply` brings up the stack; skills visible as prompts.

## Phase 4: Module 1 content
Tool-vs-skill comparison, two buildable skills, a chaining exercise, and the
contribution demo. Plus `CONTRIBUTING.md`, `showcase/` scaffolding, and the
`contributing` skill.
**Output:** `lab-01/` guide with checkpoints and solutions.

## Phase 5: Module 2 content
Change request, spec template, and the write-run-observe-tighten loop built
around an engineered, repeatable drift.
**Output:** `lab-02/` guide, spec templates, drifting v1 and tight v2.

## Phase 6: Student-facing docs
`GETTING-STARTED.md`, numbered `setup/` guides, FAQ, troubleshooting matrix,
written from the finished repo so they are accurate by construction.
**Output:** sub-30-minute setup path.

## Phase 7: Dry runs and fallbacks
Timed run-through, cold-machine test, fallback recordings, beta testers.
**Output:** timing sheet, fixed docs, recordings.

## Phase 8: Midpoint state contract
`docs/midpoint-contract.md` plus `checkpoint.sh` validating and restoring the
midpoint state.
**Output:** contract doc and script, shared with the second-half instructor.

## Dependency notes

- Phase 2's `smoke-test.sh` convergence logic is reused by the Module 1 change
  validation skill. Build it once.
- The verify script is append-only across phases; do not retrofit at the end.
- Docs (Phase 6) come after labs so they describe reality, not intent.
