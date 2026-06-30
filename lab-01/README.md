# Lab 1: From Tools to Skills

Module 1. You will see why a raw MCP tool and a structured skill are not the same
thing, build two composable skills against the live fabric, and chain them into a
workflow. The arc is deliberate: contrast first so the difference is visceral,
build second so it is hands-on, compose third so you see the payoff.

## The fabric you are working against

```
        spine1 (AS65100)      spine2 (AS65100)
        10.0.0.1/32           10.0.0.2/32
            │   │                 │   │
       ┌────┘   └────┐       ┌────┘   └────┐
     leaf1 (AS65101)          leaf2 (AS65102)
     10.0.0.101/32            10.0.0.102/32
```

Four Nokia SR Linux nodes, eBGP underlay, container names
`clab-skills-specs-lab-<node>`, credentials `admin` / `admin`. Each leaf peers
with both spines, so 2/2 sessions established is a healthy leaf. The full command
set is in [docs/quick-reference.md](../docs/quick-reference.md).

## Before you start

- Fabric deployed and healthy: `./scripts/deploy.sh && ./scripts/smoke-test.sh`.
- Stack up and client linked: `gridctl skill add https://github.com/wcollins/skills-and-specs-lab --path skills` (or `./scripts/load-skills.sh` offline), `gridctl apply stack.yaml`, `gridctl link claude-code`.
- Confirm your client sees the reference skill `network-state-query` as a prompt.

If anything is broken at any point, `./scripts/reset.sh` returns the fabric to
known-good in about 90 seconds. Do not debug a wrecked fabric live; reset and
move on.

> **Your skills survive a reset.** `reset.sh` rebuilds the fabric, not your skill
> registry. The skills you build in 1b stay in `~/.gridctl/registry/skills/`, so
> resetting the fabric between exercises never costs you your work.

## Exercises

| # | File | What you do | Time |
|---|------|-------------|------|
| 1a | [01a-tool-vs-skill.md](01a-tool-vs-skill.md) | Call a raw tool, then the same job as a skill, side by side | 10 min |
| 1b | [01b-build-skills.md](01b-build-skills.md) | Build `device-state-query` and `change-validation` | 30 min |
| 1c | [01c-chain-skills.md](01c-chain-skills.md) | Chain both skills into one workflow against the fabric | 10 min |

The module closes with an instructor demo of the `contributing` skill running the
full fork-and-pull-request flow. That is your call to action for contributing
after the workshop; you do not run it live.

## What you walk away with

Two working skills in your registry (`device-state-query`, `change-validation`),
a clear sense of when a skill earns its keep over a raw tool, and the composition
pattern you will reuse in Module 2.

Solutions live in [`solutions/`](solutions/). Use them if you fall behind; they
are the same skills you would have built.
