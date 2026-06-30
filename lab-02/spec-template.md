# Behavioral spec template

A behavioral spec is the contract between you and your agent. It says what the
agent should do, what it must not do, what a correct result looks like, and how
the agent proves it got there. Fill every section. Empty sections are where drift
lives.

---

## Intent

One sentence: what operational outcome are we actually after? Write the goal, not
the procedure.

## Inputs

The exact values the agent is given. Name them. No "the right interface"; say
which interface.

- ...

## Constraints

What the agent must and must not do. The must-nots are as important as the musts.
Include any state that must be preserved (sessions that stay up, reachability that
stays intact).

- ...

## Procedure (optional)

If the order of operations matters, state it. If it does not, say so and let the
agent choose. Be honest about which this is.

- ...

## Expected output

What the agent returns when done. A shape, not a vibe. Include the verdict field
the operator reads first.

```json
{ }
```

## Success criteria

The check that proves the intent was met, stated so there is exactly one way to
run it and one way to read the result. Name the command, the place it runs from,
and the expected result. "Confirm it works" is not a success criterion.

- ...

## Failure modes

What should happen when a precondition fails or the success check does not pass.
The agent must not report success when this section's conditions are met.

- ...
