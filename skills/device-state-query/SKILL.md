---
name: device-state-query
description: Capture one fabric node's interface and BGP state as stable, diffable JSON for other skills to compose - not for a human to read
state: draft
---

# Device state query

Use this skill when another skill, or the agent acting on its behalf, needs a
machine-consumable record of a single node's state to store or compare - for
example `change-validation`, which captures one snapshot before a change and one
after, then diffs them. The output is data, not a report: stable JSON with a
`captured_at` timestamp and no prose.

This is deliberately *not* `network-state-query`. That skill answers a human
question ("is `leaf1` healthy?") and leads with a one-line `summary`. This skill
answers no question and renders no verdict - it emits a normalized snapshot whose
only job is to diff cleanly against another snapshot of the same node.

## Scope

- In scope: a single named node, its fabric interfaces and eBGP sessions,
  serialized as deterministic JSON with a capture timestamp.
- Out of scope: any `healthy`/`summary`/human-facing field (use
  `network-state-query` for that); volatile fields that change on every read
  (uptime, counters) - they are excluded on purpose so a diff reflects real state
  change, not the passage of time; multiple nodes (call once per node);
  interpreting or diffing the result (that is the consuming skill's job); any
  configuration change.

## Steps

1. Validate the node name is one of `spine1`, `spine2`, `leaf1`, `leaf2`. If not,
   return the unknown-node error below and stop.
2. Resolve the container name: `clab-skills-specs-lab-<node>`.
3. Query interface state:
   `docker exec clab-skills-specs-lab-<node> sr_cli "show interface brief"`
4. Query BGP neighbor state:
   `docker exec clab-skills-specs-lab-<node> sr_cli "show network-instance default protocols bgp neighbor"`
5. Reduce both to the fields in the Output section. Drop volatile fields
   (uptime, packet/prefix counters). Do not paste raw CLI output.
6. Normalize for stable comparison: sort `interfaces` by `name` and `bgp` by
   `peer` (ascending, string order), and emit object keys in the order shown
   below. Two captures of an unchanged node must be byte-identical except for
   `captured_at`.
7. Stamp `captured_at` with the current UTC time in RFC 3339 (`Z`) form.

## Output

Return exactly this structure (JSON), nothing more. No prose before or after.

```json
{
  "node": "leaf1",
  "captured_at": "2026-06-29T14:03:11Z",
  "interfaces": [
    {"name": "ethernet-1/1", "admin": "enable", "oper": "up"},
    {"name": "ethernet-1/2", "admin": "enable", "oper": "up"},
    {"name": "system0",      "admin": "enable", "oper": "up"}
  ],
  "bgp": [
    {"peer": "10.1.1.1", "peer_as": 65100, "state": "established"},
    {"peer": "10.2.1.1", "peer_as": 65100, "state": "established"}
  ]
}
```

`captured_at` is metadata, not state: a consuming diff (e.g. `change-validation`)
must ignore it and compare only `interfaces` and `bgp`. Everything else in the
object is the comparable state.

## Failure modes

Errors are structured too, so a consuming skill can branch on them instead of
parsing prose.

- **Node not in the fabric:** return
  `{"node": "<name>", "error": "unknown node", "valid": ["spine1","spine2","leaf1","leaf2"]}`.
- **Container not running:** return
  `{"node": "<node>", "error": "container not running", "hint": "./scripts/deploy.sh"}`.
- **BGP still converging (any session in `active`/`connect`):** still emit the
  full snapshot - record the real states verbatim, do not coerce them to
  `established`. The snapshot reports state; it does not judge it.
