---
name: change-validation
description: Snapshot a node's state before and after a change, then report exactly what changed and whether the fabric is still healthy
state: draft
---

# Change validation

Lab 1b solution and the second composable skill. Use this skill to wrap any
network change in a pre/post check so you can prove the change did what you
intended and broke nothing else. It composes `device-state-query`: same snapshot
shape before and after, then a diff. This is the skill form of the `smoke-test.sh`
discipline.

## Scope

Validates the effect of one change on one or more named nodes. It does NOT make
the change; the operator (or another skill) applies the change between the two
snapshots. Read-only on both ends.

## Steps

1. **Pre-snapshot.** For each node in scope, capture state using the
   `device-state-query` procedure. Store as `before`.
2. **Hand back.** Tell the operator the pre-snapshot is captured and to apply
   their change now. Wait for confirmation that the change is applied.
3. **Post-snapshot.** Capture the same nodes again. Store as `after`.
4. **Diff.** Compare `before` and `after` field by field:
   - interfaces that changed oper state,
   - BGP sessions that changed state (established -> not, or the reverse),
   - new or removed neighbors.
5. **Judge.** The change is `valid` only when the intended difference appears AND
   no unintended regressions appear (no session that was established is now down,
   no interface that was up is now down, unless that was the stated intent).

## Output

```json
{
  "nodes": ["leaf1"],
  "intent": "<one line the operator gave>",
  "changed": [
    {"node": "leaf1", "field": "bgp[10.1.1.1].state", "before": "established", "after": "established"}
  ],
  "regressions": [],
  "valid": true,
  "summary": "Change applied. No regressions. 2/2 BGP sessions still established."
}
```

## Failure modes

- **Operator never confirms the change:** do not fabricate a post-snapshot; stop
  and report `valid: false, reason: "change not confirmed"`.
- **Pre-snapshot itself unhealthy:** warn loudly before the change; you cannot
  validate a change from a broken baseline. Suggest `./scripts/reset.sh`.
- **A regression appears:** set `valid: false`, list every regression, and
  recommend rollback. Never report `valid: true` with a non-empty `regressions`.
