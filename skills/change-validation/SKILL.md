---
name: change-validation
description: Snapshot one or more fabric nodes before and after an operator applies a change, diff the snapshots, and report whether the change is valid with no regressions
state: draft
---

# Change validation

Use this skill when an operator is about to make a change to the lab fabric (an
interface shut, a BGP reconfig, a config push) and wants proof afterward that the
change did what they intended and broke nothing else. The skill captures a
*before* snapshot of every named node, waits for the operator to apply the
change out of band, captures an *after* snapshot, diffs the pair per node, and
renders a single pass/fail verdict.

This skill does **not** make the change. It is a harness around someone else's
change, not the change itself — the clab MCP server is read-only by design, and
the operator applies the change however they normally would. This skill's whole
value is the before/after discipline: a verdict you can trust because both
snapshots were taken the same way.

It composes [[device-state-query]] rather than querying devices itself. That
skill already emits stable, diffable JSON per node; this skill orchestrates two
captures of it and interprets the delta. Do not reimplement the CLI queries here.

## Scope

- In scope: orchestrating before/after snapshots for one or more named nodes,
  diffing each node's `interfaces` and `bgp` state, and classifying every
  transition as *intended* (matches the operator's stated expectation) or a
  *regression* (an unannounced move away from a healthy state).
- Out of scope: applying the change (the operator does that); config-text
  diffing (this compares operational state, not config); multi-fabric or
  non-lab nodes; capturing state itself — delegate every snapshot to
  `device-state-query` so both captures are byte-identical in method.

## Inputs

- `nodes`: one or more of `spine1`, `spine2`, `leaf1`, `leaf2`. Snapshot every
  node the change could plausibly touch, not only the one being configured — a
  regression often shows up on a *neighbor* (a flapped BGP session, a downed
  peer interface), which is exactly what before/after is for.
- `expected` (optional): a short description of the intended effect, e.g.
  "`leaf1` ethernet-1/2 goes admin-down" or "no operational change, config-only".
  Used to separate intended transitions from regressions. If omitted, treat
  **every** move away from `up`/`established` as a candidate regression and say
  so — without a stated intent the skill cannot tell a deliberate shut from a
  fault.

## Steps

1. Validate every name in `nodes` against `spine1`, `spine2`, `leaf1`, `leaf2`.
   On any unknown name, return the unknown-node error and stop before capturing
   anything — a partial baseline is worse than none.
2. **Capture the baseline.** For each node, invoke `device-state-query` and store
   its JSON snapshot keyed by node. If any baseline capture returns an error
   (container not running, etc.), stop and surface it — you cannot validate a
   change against a baseline you never took.
3. **Pause for the operator.** Tell the operator the baseline is captured and
   wait for them to confirm the change has been applied. Do not proceed on a
   timer and do not apply anything yourself.
4. **Capture the after-state.** For each node, invoke `device-state-query` again
   and store the second snapshot.
5. **Diff per node.** Compare baseline and after for each node, ignoring
   `captured_at`. Record every interface whose `admin`/`oper` changed and every
   BGP peer whose `state` changed, appeared, or disappeared.
6. **Classify each transition.** A transition matching `expected` is `intended`.
   A move *toward* health (`down`→`up`, `active`→`established`) is `recovered`.
   Any other move *away* from health (`up`→`down`, `established`→anything else,
   a peer that vanished) is a `regression`. With no `expected` given, classify
   every away-from-health move as `regression` and flag that intent was unstated.
7. **Render the verdict.** `valid` is `true` only when there are zero
   `regression` transitions across all nodes. Intended and recovered transitions
   do not fail the verdict.

## Output

Return exactly this structure (JSON), nothing more.

```json
{
  "nodes": ["leaf1", "spine1"],
  "expected": "leaf1 ethernet-1/2 goes admin-down",
  "valid": false,
  "diffs": [
    {
      "node": "leaf1",
      "interfaces": [
        {"name": "ethernet-1/2", "from": {"admin": "enable", "oper": "up"},
         "to": {"admin": "disable", "oper": "down"}, "class": "intended"}
      ],
      "bgp": []
    },
    {
      "node": "spine1",
      "interfaces": [],
      "bgp": [
        {"peer": "10.1.1.2", "from": "established", "to": "active",
         "class": "regression"}
      ]
    }
  ],
  "regressions": [
    "spine1: BGP peer 10.1.1.2 went established -> active"
  ],
  "summary": "INVALID: 1 intended change confirmed, 1 regression on spine1 (BGP peer 10.1.1.2 dropped)."
}
```

A node with no changes still appears in `diffs` with empty `interfaces` and
`bgp` arrays — "nothing changed here" is a result, and its absence would read as
"not checked." The one-line `summary` leads with `VALID` or `INVALID` and is what
the operator reads first.

## Failure modes

- **Unknown node in `nodes`:** return
  `{"error": "unknown node <name>", "valid": ["spine1","spine2","leaf1","leaf2"]}`
  and capture nothing.
- **Baseline capture fails for any node:** stop and return
  `{"phase": "baseline", "node": "<node>", "error": "<error from device-state-query>"}`.
  Never proceed to the change with an incomplete baseline.
- **After capture fails for any node:** return
  `{"phase": "after", "node": "<node>", "error": "<error>", "hint": "baseline was captured; re-run after capture once the node is reachable"}`
  rather than discarding the baseline.
- **No change detected** (every diff is empty): return `valid: true` with
  `summary: "No operational change detected — did the change get applied?"` so the
  operator can tell a clean change apart from a forgotten one.
- **After-state still converging** (a BGP peer in `active`/`connect` that was
  `established` before): report it as a `regression` but note in `summary` that
  the fabric may still be converging; suggest re-running the after capture in 30
  seconds before treating it as a confirmed regression.
