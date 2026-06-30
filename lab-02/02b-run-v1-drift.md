# Lab 2b - Run v1 and watch it drift

> **You are here:** Module 2 - Spec-Driven Development - Exercise 2b of 3 - ~12 min

You will hand the agent a deliberately loose spec, let it make the change on
`leaf1`, and then run the real check from `leaf2`. The agent will report success
while the operational goal is not met. That gap is the lesson.

## Run v1

Use the prewritten loose spec so the whole room drifts the same way. Hand your
agent the contents of
[solutions/spec-v1-drifting.md](solutions/spec-v1-drifting.md) and let it make
the change against `leaf1`.

**Prompt your client:**

> Here is the spec. Follow it exactly and make the change on leaf1.
> [paste the contents of lab-02/solutions/spec-v1-drifting.md]

The agent does the obvious thing: it creates `lo0`, sets `10.50.0.1/32`, enables
it, and then satisfies "confirm the new address works" with the easiest available
check, a local ping on `leaf1`.

**The check the agent picks (local, passes):**

```bash
docker exec clab-skills-specs-lab-leaf1 sr_cli "ping network-instance default 10.50.0.1 -c 2"
```

That succeeds, because the address is local to `leaf1`. The agent reports done.

> **Expected, not broken:** the agent reporting success here is *correct behavior
> for v1*. It satisfied a loose contract exactly as written. The agent did not
> break and it did not lie. The spec is the problem, and you are about to prove
> it.

## Run the real check, from leaf2

Now run the check the spec should have named, from the other leaf:

```bash
docker exec clab-skills-specs-lab-leaf2 sr_cli "ping network-instance default 10.50.0.1 -c 2"
```

This fails. The loopback was never placed in `network-instance default`, so the
accept-all export policy never advertised it, so `leaf2` has no route to it.

## Why it drifted

Two gaps did this, and neither is the agent's fault:

1. The spec never made "advertised into the fabric" a constraint, so the step
   that places `lo0.0` into `network-instance default` was optional.
2. The success criterion was "confirm the new address works", which does not say
   from where, so the agent picked the check that passes.

## Checkpoint (the halfway gate)

> The ping from `leaf2` fails, even though the agent said the change was done.
> Confirm you see that failure before moving on. Per the live contract, nobody
> starts tightening until everyone has seen the drift from `leaf2`. If you skip
> this, you skipped the module.

Continue to [02c-tighten-v2.md](02c-tighten-v2.md).
