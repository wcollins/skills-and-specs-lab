# Constitution: Skills & Specs Lab

The non-negotiable principles every build decision in this repository answers to.
This is the dogfood artifact for Module 2: the workshop was specced before it was
built, and this file is the contract every Claude Code session worked against.

## Article I: The student never loses their lab

A student's environment is sacred. No agent, lab step, or demo may put a student
in a state they cannot recover from in under two minutes. `reset.sh` is the
guaranteed escape hatch and must always return a known-good fabric. The topology
is deployed deterministically by `deploy.sh`, never by an agent during a lab.

## Article II: Least privilege is shown in config, not prose

Where the workshop teaches least privilege, it demonstrates it in working
configuration. The clab MCP server is filtered to read-only tools in
`stack.yaml`, not merely described as "scoped." The config is the lesson.

## Article III: Portability is a requirement, not a nicety

Claude Code is the worked example, but no artifact may hard-depend on it.
Everything student-facing speaks "your MCP client." The gateway is one endpoint;
clients are interchangeable through `gridctl link`.

## Article IV: Determinism over cleverness

Engineered, reproducible behavior beats impressive but flaky behavior. The
Module 2 drift exercise must drift the same way every run; if it only drifts
sometimes, the trap is redesigned. Demos have recorded fallbacks.

## Article V: Skills and specs are durable artifacts

Skills follow the agentskills.io `SKILL.md` standard so they survive the
workshop and work in any skill-aware client. Specs are first-class engineering
artifacts, version-controlled and iterated, not prompt tricks.

## Article VI: The midpoint is deterministic

Every student crosses the midpoint of the workshop in a known, verifiable state
regardless of how their individual labs went. `checkpoint.sh` validates and, if
needed, restores that state.

## Article VII: The door stays open without becoming an obligation

Post-workshop contribution is a learning exercise, not a contribution-volume
goal. Review is best-effort and a teaching moment. Core `skills/` stays curated;
`showcase/` is the open floor.
