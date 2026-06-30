# Spec v1 (under-specified, drifts on purpose)

This is a faithful, loose write-up of the change request. It is not wrong, it is
just under-specified in two specific places. Run it, then verify from `leaf2`.

---

## Intent

Put a new service address on leaf1 and make it reachable from the other leaf.

## Inputs

- Node: `leaf1`
- Address: `10.50.0.1/32` on a new loopback (`lo0`)

## Constraints

- Do not disturb existing interfaces or BGP sessions.

## Expected output

A note that the address is configured and reachable.

## Success criteria

- Confirm the new address works.

## Failure modes

- If the address cannot be configured, report the error.

---

## What happens when you run this

The agent reproducibly does the obvious thing: creates `lo0`, sets
`10.50.0.1/32`, enables it, and then satisfies "confirm the new address works"
with the easiest available check, a local ping on `leaf1`:

```bash
docker exec clab-skills-specs-lab-leaf1 sr_cli "ping network-instance default 10.50.0.1 -c 2"
```

That succeeds, because the address is local to leaf1. The agent reports done.

Now run the real check, from `leaf2`:

```bash
docker exec clab-skills-specs-lab-leaf2 sr_cli "ping network-instance default 10.50.0.1 -c 2"
```

It fails. The loopback was never placed in `network-instance default`, so the
accept-all export policy never advertised it, so `leaf2` has no route to it. The
intent ("reachable from the other leaf") is not met, but the spec let the agent
declare success anyway.

Two gaps did this, and neither is the agent's fault:

1. The spec never made "advertised into the fabric" a constraint, so the step
   that places `lo0.0` into `network-instance default` was optional.
2. The success criterion was "confirm the new address works," which does not say
   from where, so the agent picked the check that passes.

Tighten both in [spec-v2-tight.md](spec-v2-tight.md).
