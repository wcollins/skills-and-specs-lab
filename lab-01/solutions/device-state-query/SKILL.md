---
name: device-state-query
description: Query one fabric node and return its interface and BGP state as structured JSON
state: draft
---

# Device state query

Lab 1b solution. Use this skill to get the current operational state of a single
node in the lab fabric as structured data that another skill or a human can act
on. This is the first of the two composable skills; `change-validation` calls it
to snapshot state before and after a change.

## Scope

One node, read-only. Nodes: `spine1`, `spine2`, `leaf1`, `leaf2`.

## Steps

1. Validate `<node>` is a known fabric node; otherwise return an error object.
2. Container name is `clab-skills-specs-lab-<node>`.
3. Run, capturing output:
   - `docker exec clab-skills-specs-lab-<node> sr_cli "show interface brief"`
   - `docker exec clab-skills-specs-lab-<node> sr_cli "show network-instance default protocols bgp neighbor"`
4. Extract per-interface admin/oper state and per-neighbor peer, peer-AS, and
   session state.

## Output

```json
{
  "node": "<node>",
  "captured_at": "<iso8601>",
  "interfaces": [{"name": "ethernet-1/1", "oper": "up"}],
  "bgp": [{"peer": "10.1.1.1", "peer_as": 65100, "state": "established"}],
  "healthy": true
}
```

Keep the structure stable across calls. `change-validation` diffs two of these,
so field names and shape must not vary between the pre and post snapshot.

## Failure modes

- Unknown node: `{"error": "unknown node <name>"}`.
- Container down: `{"node": "<node>", "error": "container not running"}`.
- Empty or unparseable CLI output: return `healthy: false` with a `note`, never a
  half-parsed object.
