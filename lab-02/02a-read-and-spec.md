# Lab 2a - Read the request and (optionally) write a spec

> **You are here:** Module 2 - Spec-Driven Development - Exercise 2a of 3 - ~5 min

The goal of this short opener is to feel how an under-specified request arrives,
and to notice the two gaps in it before the agent does.

## Read the request

Open [change-request.md](change-request.md) and read it like it landed in your
queue. It is informal and plausible: put `10.50.0.1/32` on a new loopback on
`leaf1` and make it reachable from the other leaf.

As you read, find the two things it leaves open:

1. It never says how to confirm "reachable", or from where.
2. It says nothing about routing, and a loopback with an address is not
   automatically reachable from elsewhere in the fabric.

Those two gaps are the entire module. Hold onto them.

## Optional: write your own loose spec first

If you want the lesson to land harder, take the request into
[spec-template.md](spec-template.md) and write your own behavioral spec before
you look at the prewritten one. Give yourself about five minutes. Do not
over-think it; write it the way the request reads.

Most people reproduce the same two gaps the prewritten v1 has, which is the
point: a faithful spec of a loose request is a loose spec. You will compare yours
against `solutions/spec-v1-drifting.md` in the next exercise.

## Checkpoint

> You can name, in one sentence each, the two gaps in the change request: no
> located success check, and no routing/advertisement requirement. Next you run a
> spec that has both gaps and watch the agent satisfy it anyway.

Continue to [02b-run-v1-drift.md](02b-run-v1-drift.md).
