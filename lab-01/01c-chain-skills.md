# Lab 1c: Chain the skills into a workflow

Goal: compose the two skills into one workflow that validates a real change
against the fabric. This is the payoff: skills are worth building because they
compose.

## The change

Add a second loopback address to `leaf1` and confirm the fabric stays healthy.
This is a small, safe, reversible change that exercises the full pre/post loop.

The change itself (you apply it between the snapshots):

```bash
docker exec clab-skills-specs-lab-leaf1 sr_cli -ec \
  "set / interface system0 subinterface 0 ipv4 address 10.0.0.201/32" \
  "commit now"
```

Roll it back with:

```bash
docker exec clab-skills-specs-lab-leaf1 sr_cli -ec \
  "delete / interface system0 subinterface 0 ipv4 address 10.0.0.201/32" \
  "commit now"
```

## The workflow

Ask your client to run the whole thing as one flow:

> Use change-validation to validate this change on leaf1, intent "add second
> loopback 10.0.0.201/32." Take the pre-snapshot, then tell me to apply the
> change. After I confirm, take the post-snapshot and give me the verdict.

Under the hood: `change-validation` calls `device-state-query` for the
pre-snapshot, hands back to you, you apply the change, you confirm, it calls
`device-state-query` again for the post-snapshot, diffs them, and judges.

## Checkpoint

> The workflow should report `valid: true` with `regressions: []`, and the
> `summary` should note that all BGP sessions stayed established. The added
> loopback shows up as a change, nothing else does.

Now break it on purpose. Re-run the workflow, but this time "apply the change" by
shutting a fabric interface instead:

```bash
docker exec clab-skills-specs-lab-leaf1 sr_cli -ec \
  "set / interface ethernet-1/1 admin-state disable" "commit now"
```

> The workflow should now report `valid: false`, list the dropped BGP session as a
> regression, and recommend rollback. Re-enable the interface (`admin-state
> enable`, `commit now`) or just run `./scripts/reset.sh`.

## What you just proved

Two single-purpose skills, composed, caught a regression automatically. No new
code, no new tool. You described the workflow in one sentence and the skills did
the structured work. That composition is the whole reason to prefer skills over
raw tools once a job has more than one step.

## Module close: the contribution demo

Instructor only task! We will use the `contributing` skill end to end: fork, branch, open
a pull request. That is the call to action. After the workshop, you will run that
same skill to contribute a skill or a lab of your own. See
[`CONTRIBUTING.md`](../CONTRIBUTING.md). Nothing about it is on the live critical
path today, so there is no GitHub setup for you to do right now.
