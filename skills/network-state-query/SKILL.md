---
name: network-state-query
description: Return a focused, structured health summary for one fabric node (interfaces and BGP), instead of a raw tool dump
state: active
---

# Network state query

Use this skill when someone asks "is `<node>` healthy?" or "what is the state of
`<node>`?" for a node in the Skills & Specs Lab fabric (`spine1`, `spine2`,
`leaf1`, `leaf2`). This is the reference skill: it sets the quality bar for the
skills you build in Lab 1. Study its shape before writing your own.

The point of a skill over a raw tool: a raw tool (for example the clab
`inspectLab` tool) hands back a firehose of generic data and leaves you to find
the answer. This skill asks the operational question directly and returns a
scoped, labeled, structured result.

## Scope

- In scope: operational state of a single named node, interfaces and eBGP.
- Out of scope: changing configuration, querying multiple nodes at once
  (call this once per node), anything outside the lab fabric.

## Steps

1. Validate the node name is one of `spine1`, `spine2`, `leaf1`, `leaf2`. If not,
   stop and say so.
2. Resolve the container name: `clab-skills-specs-lab-<node>`.
3. Query interface state:
   `docker exec clab-skills-specs-lab-<node> sr_cli "show interface brief"`
4. Query BGP neighbor state:
   `docker exec clab-skills-specs-lab-<node> sr_cli "show network-instance default protocols bgp neighbor"`
5. Parse both. Do not paste raw CLI output back; extract the fields below.

## Output

Return exactly this structure (JSON), nothing more:

```json
{
  "node": "leaf1",
  "interfaces": [
    {"name": "ethernet-1/1", "admin": "enable", "oper": "up"},
    {"name": "ethernet-1/2", "admin": "enable", "oper": "up"},
    {"name": "system0",      "admin": "enable", "oper": "up"}
  ],
  "bgp": [
    {"peer": "10.1.1.1", "peer_as": 65100, "state": "established", "uptime": "0:12:30"},
    {"peer": "10.2.1.1", "peer_as": 65100, "state": "established"}
  ],
  "healthy": true,
  "summary": "leaf1: 3/3 interfaces up, 2/2 BGP sessions established."
}
```

`healthy` is `true` only when every fabric interface is `up` and every BGP
session is `established`. The one-line `summary` is what a human reads first.

## Failure modes

- **Node not in the fabric:** return `{"error": "unknown node <name>", "valid": ["spine1","spine2","leaf1","leaf2"]}`.
- **Container not running:** return `{"node": "<node>", "error": "container not running", "hint": "./scripts/deploy.sh"}`.
- **BGP still converging (sessions in `active`/`connect`):** report `healthy: false`
  and note in `summary` that the fabric may still be converging; suggest re-running
  after 30 seconds.
