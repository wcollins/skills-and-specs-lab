# Lab 1b: Build two composable skills

Goal: build two skills from scratch that follow the quality bar set by
`network-state-query`. You will reuse them in 1c and in Module 2.

Use the `skills-creator` skill (it is in your registry) to scaffold each one,
then refine. The discipline you are practicing: one job per skill, a defined
output shape, and named failure modes.

> **Where your skill lands:** built skills are written to
> `~/.gridctl/registry/skills/<name>/SKILL.md`. If your client does not see a
> skill after you save it, check that the file is there and that you ran
> `gridctl activate <name>`. These skills live in the registry, not the fabric,
> so they survive `./scripts/reset.sh`.

## Skill 1: device-state-query

A read-only skill that returns one node's interface and BGP state as stable,
structured JSON. It is deliberately narrower than the reference skill: no
human-facing prose, just a clean data structure other skills can consume.

1. Invoke `skills-creator`. Give it this scope: "A machine-consumable state
   snapshot for one fabric node: interfaces and BGP as stable JSON with a
   `captured_at` timestamp and no human-facing prose. Built to be composed by
   other skills — `change-validation` diffs two of these — not read by a human,
   which is what distinguishes it from `network-state-query`. Read-only, one node
   per call."
2. It will ask you for the trigger, scope, inputs/outputs, and failure modes.
   Answer them. The inputs are a node name; the output is the JSON below.
3. The two queries the skill runs (via your client's shell):
   ```bash
   docker exec clab-skills-specs-lab-<node> sr_cli "show interface brief"
   docker exec clab-skills-specs-lab-<node> sr_cli "show network-instance default protocols bgp neighbor"
   ```
4. The output shape, which must not vary between calls:
   ```json
   {
     "node": "<node>",
     "captured_at": "<iso8601>",
     "interfaces": [{"name": "ethernet-1/1", "oper": "up"}],
     "bgp": [{"peer": "10.1.1.1", "peer_as": 65100, "state": "established"}],
     "healthy": true
   }
   ```
5. Save it to your registry and activate it:
   ```bash
   gridctl skill validate device-state-query
   gridctl activate device-state-query
   ```

Stuck? The reference solution is
[`solutions/device-state-query/SKILL.md`](solutions/device-state-query/SKILL.md).

### Checkpoint

> Invoke `device-state-query` for `leaf1`. You should get back a JSON object with
> `interfaces`, `bgp`, and `healthy: true`, and the exact same shape when you run
> it for `spine1`.

## Skill 2: change-validation

A skill that wraps a change in a pre/post check and reports what actually changed.
This is the `smoke-test.sh` discipline turned into a reusable skill, and it
composes `device-state-query`: same snapshot before and after, then a diff.

1. Invoke `skills-creator` with this scope: "Snapshot one or more nodes before
   and after an operator-applied change, diff the two snapshots, and report
   whether the change is valid with no regressions. Does not make the change."
2. Build the procedure as five steps: pre-snapshot (reuse `device-state-query`),
   hand back to the operator, post-snapshot, diff, judge.
3. The judgment rule that matters: the change is `valid` only when the intended
   difference appears AND no session that was established is now down and no
   interface that was up is now down. A non-empty `regressions` list means
   `valid: false`, always.
4. Output shape:
   ```json
   {
     "nodes": ["leaf1"],
     "intent": "<one line>",
     "changed": [{"node": "leaf1", "field": "...", "before": "...", "after": "..."}],
     "regressions": [],
     "valid": true,
     "summary": "..."
   }
   ```
5. Validate and activate:
   ```bash
   gridctl skill validate change-validation
   gridctl activate change-validation
   ```

Reference solution:
[`solutions/change-validation/SKILL.md`](solutions/change-validation/SKILL.md).

### Checkpoint

> Invoke `change-validation` for `leaf1` with intent "no-op test." Let it take the
> pre-snapshot, make no change, confirm, and let it take the post-snapshot. It
> should report `valid: true`, `changed: []`, `regressions: []`. A validator that
> finds no change on a no-op is a validator you can trust on a real change.

## Why two skills, not one

You could have written a single "check and validate" skill. You did not, because
`device-state-query` does one job (read state) and `change-validation` does
another (judge a change), and the first is useful on its own and reusable by the
second. That separation is what makes 1c possible.
