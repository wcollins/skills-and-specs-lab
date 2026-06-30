# Spec v2 (tightened, holds)

Same intent, same agent, same tools. The only change is the spec. Two additions
remove the drift: a named constraint that forces advertisement, and a success
criterion with exactly one way to run it and read it.

---

## Intent

Make `10.50.0.1/32` reachable from `leaf2` by hosting it on a new loopback on
`leaf1` and advertising it into the fabric underlay.

## Inputs

- Node: `leaf1`
- Address: `10.50.0.1/32`
- Loopback interface: `lo0`, subinterface `0`
- Routing instance: `default`

## Constraints

- The loopback subinterface `lo0.0` MUST be placed in `network-instance default`.
  This is what the existing accept-all export policy needs in order to advertise
  the prefix. An address configured but not in the routing instance is not done.
- Do not modify any existing interface, subinterface, BGP neighbor, or policy.
- All four existing BGP sessions must remain `established` after the change.

## Procedure

1. Create `lo0` and `lo0.0`, address `10.50.0.1/32`, admin-state enable at each
   level.
2. Add `lo0.0` to `network-instance default`.
3. Commit.

The exact commands:

```bash
docker exec clab-skills-specs-lab-leaf1 sr_cli -ec \
  "set / interface lo0 admin-state enable" \
  "set / interface lo0 subinterface 0 ipv4 admin-state enable" \
  "set / interface lo0 subinterface 0 ipv4 address 10.50.0.1/32" \
  "set / network-instance default interface lo0.0" \
  "commit now"
```

## Expected output

```json
{
  "node": "leaf1",
  "address": "10.50.0.1/32",
  "in_routing_instance": true,
  "reachable_from_leaf2": true,
  "bgp_sessions_established": 4,
  "done": true
}
```

## Success criteria

The change is done only when this exact check, run from `leaf2`, returns replies:

```bash
docker exec clab-skills-specs-lab-leaf2 sr_cli "ping network-instance default 10.50.0.1 -c 2"
```

A local ping on `leaf1` is not acceptable proof. The check runs from `leaf2`.

## Failure modes

- If the `leaf2` ping does not return replies, the change is NOT done. Do not
  report success. Most likely cause: `lo0.0` was not added to
  `network-instance default`. Add it and re-check.
- If any previously established BGP session is no longer established, roll back
  and report a regression.

## Rollback

```bash
docker exec clab-skills-specs-lab-leaf1 sr_cli -ec \
  "delete / interface lo0" \
  "delete / network-instance default interface lo0.0" \
  "commit now"
```

Or simply `./scripts/reset.sh`.

---

## What changed, and why it worked

You did not touch the agent, its tools, or its prompt. You changed the contract.
The named constraint made the advertisement step mandatory instead of optional,
and the single, located success check ("ping from leaf2") removed the agent's
freedom to pick a check that passes for the wrong reason. That is spec-driven
development: behavior tightened through the spec, auditable and repeatable.
