# Lab 2: Spec-Driven Development for Agent Behavior

Module 2. Agents that work in a demo fail in production because the expected
behavior was never written down. Here you treat a behavioral spec as the contract
between you and your agent: write it, run the agent against the fabric, watch
where it drifts, tighten the spec, and rerun. No agent code changes, only the
spec.

## The loop

```
   write spec  ->  run agent against fabric  ->  observe drift
        ^                                              |
        |                                              v
   tighten spec  <-------------------------------  it drifted
```

You will run this loop once with a deliberately under-specified spec that drifts
in a repeatable way, then once with a tightened spec that does not.

## The fabric (why leaf2 is the real check)

```
        spine1 (AS65100)      spine2 (AS65100)
            │   │                 │   │
       ┌────┘   └────┐       ┌────┘   └────┐
     leaf1 (AS65101)          leaf2 (AS65102)
        │                                │
   new loopback 10.50.0.1/32      runs the real reachability check
```

The change is applied on `leaf1`, but the operational goal is reachability from
`leaf2`. A loopback address is local to `leaf1` until it is advertised into the
eBGP underlay, so the only honest proof is a ping from `leaf2`. That split
between where the change lands and where it must be proven is what the loose spec
ignores.

## Exercises

| # | File | What you do | Time |
|---|------|-------------|------|
| 2a | [02a-read-and-spec.md](02a-read-and-spec.md) | Read the request, find its two gaps, optionally draft your own spec | 5 min |
| 2b | [02b-run-v1-drift.md](02b-run-v1-drift.md) | Run the loose spec, then check from `leaf2` and watch it drift | 12 min |
| 2c | [02c-tighten-v2.md](02c-tighten-v2.md) | Reset, tighten the spec, rerun, confirm the drift is gone | 15 min |

## Files

| File | What it is |
|------|------------|
| [change-request.md](change-request.md) | The plain-language request, as an operator would hand it to you |
| [spec-template.md](spec-template.md) | The blank behavioral spec template (inputs, constraints, outputs, failure modes) |
| [solutions/spec-v1-drifting.md](solutions/spec-v1-drifting.md) | The under-specified spec that drifts |
| [solutions/spec-v2-tight.md](solutions/spec-v2-tight.md) | The tightened spec that holds |
| [solutions/WHAT-CHANGED.md](solutions/WHAT-CHANGED.md) | Side-by-side of the two edits that remove the drift |

> **Tool definitions are implicit here.** The agent acts through your MCP client
> using `docker exec ... sr_cli` against the nodes; there is no separate "tool
> definitions" artifact to write. In this module the spec *is* the contract: it
> constrains behavior, not the client or the SDK.

### Halfway checkpoint (live session)

> Everyone has run v1 and confirmed, from `leaf2`, that the service address is NOT
> reachable, even though the agent said the change was done. Nobody starts
> tightening until everyone has seen the drift.

## Final checkpoint

> With v2, `docker exec clab-skills-specs-lab-leaf2 sr_cli "ping network-instance
> default 10.50.0.1 -c 2"` returns replies. The agent does not report success
> until that check passes. Same agent, tighter contract, predictable behavior.

## Reset

`./scripts/reset.sh` removes any half-applied change and returns the fabric to
known-good between runs.

---

## Instructor note (not student-facing)

The drift here is engineered around two things the loose spec leaves open: (1) it
never requires the new loopback to be placed in `network-instance default`, which
is what the accept-all export policy needs in order to advertise it, and (2) its
success criterion is the vague "confirm it works," which the agent reproducibly
satisfies with a local ping on `leaf1`. The fabric guarantees the failure: an
interface not in the routing instance is never advertised, so `leaf2` cannot reach
it. Per the risk register, validate that this reproduces across 5+ runs and two
model versions before the event, and re-run it 48 hours before. If a model starts
reliably adding the network-instance membership on its own, tighten the trap (for
example, ask for the address on a new `lo0` and remove the accept-all hint from
the request).
