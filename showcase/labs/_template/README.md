# Lab title

Copy this template to start a showcase lab. Copy `showcase/labs/_template/` to
`showcase/labs/<your-name>/` and fill in each section. Replace this heading with
a short, specific lab title. Remember that other people will run this lab, so it
must be safe: no destructive commands, no secrets, no prompt-injection payloads,
and no calls to untrusted endpoints. See [`../../README.md`](../../README.md)
for the showcase safety rules and [`../../../CONTRIBUTING.md`](../../../CONTRIBUTING.md)
for the contribution flow.

## What this lab teaches

State the one idea a reader walks away with. Keep it to a sentence or two. Name
the skill, spec, or tool the lab exercises.

## Prerequisites

List what must already be true before a reader starts. For example:

- The fabric is deployed and converged (`./scripts/deploy.sh`, then
  `./scripts/smoke-test.sh`).
- The relevant skill is imported and active (`gridctl skill add ...`, then
  `gridctl activate <name>`).
- An MCP client is linked (`gridctl link <client>`).

## Steps

Number the steps so a reader can follow them top to bottom. Show exact commands.
Use only the read-only clab tools and the sanctioned scripts; do not deploy or
destroy the fabric from inside a step.

1. First action, with the command.
2. Next action, with what to look for in the output.
3. Continue until the reader reaches the checkpoint.

## Checkpoint

State what success looks like in concrete terms: "you should now see X." Give
the reader a single observable signal (a command output, a status, or a value)
that confirms the lab worked.

## Cleanup

Tell the reader how to return to a clean state. Keep this non-destructive to the
shared fabric. For example, deactivate or remove a skill you imported for the
lab:

```bash
gridctl skill remove <name>
```

If the lab changed nothing that needs undoing, say so.
