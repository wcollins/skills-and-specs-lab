# Lab 2c - Tighten to v2 and rerun

> **You are here:** Module 2 - Spec-Driven Development - Exercise 2c of 3 - ~15 min

Now you close both gaps, in the spec and only in the spec. Same agent, same
tools, same prompt. The drift disappears.

## Reset first

Clear the half-applied v1 change so everyone starts clean:

```bash
./scripts/reset.sh        # removes the 10.50.0.1 loopback, back to known-good (~90s)
```

## What changes in v2

Two additions, both in [solutions/spec-v2-tight.md](solutions/spec-v2-tight.md):

1. A named constraint that the loopback subinterface `lo0.0` MUST be placed in
   `network-instance default`. That is what the accept-all export policy needs in
   order to advertise the prefix, so advertisement becomes mandatory instead of
   optional.
2. A single, located success check: ping from `leaf2` must return replies, and a
   local ping on `leaf1` is explicitly not acceptable proof.

A side-by-side of exactly what changed is in
[solutions/WHAT-CHANGED.md](solutions/WHAT-CHANGED.md).

## Rerun with v2

**Prompt your client:**

> Here is the corrected spec. Follow it exactly, and do not report success until
> the success criterion passes.
> [paste the contents of lab-02/solutions/spec-v2-tight.md]

This time the agent runs the full procedure, including the step that puts the
loopback in the routing instance:

```bash
docker exec clab-skills-specs-lab-leaf1 sr_cli -ec \
  "set / interface lo0 admin-state enable" \
  "set / interface lo0 subinterface 0 ipv4 admin-state enable" \
  "set / interface lo0 subinterface 0 ipv4 address 10.50.0.1/32" \
  "set / network-instance default interface lo0.0" \
  "commit now"
```

It cannot declare victory until the `leaf2` check passes.

## Verify it yourself

```bash
docker exec clab-skills-specs-lab-leaf2 sr_cli "ping network-instance default 10.50.0.1 -c 2"
```

This time it returns replies.

## Checkpoint (final)

> The ping from `leaf2` returns replies, and the agent does not report success
> until that check passes. Same agent, same tools, same prompt. The only thing
> that changed was the spec. That is spec-driven development: behavior you
> tightened through the contract, auditable and repeatable, without ever touching
> the agent.

If anything is half-applied between runs, `./scripts/reset.sh` returns the fabric
to known-good. When you are done, run `./scripts/checkpoint.sh` to confirm your
midpoint state is green.
