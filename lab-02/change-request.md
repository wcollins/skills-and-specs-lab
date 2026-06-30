# Change request (as received)

This is the kind of request that lands in your queue: informal, plausible, and
under-specified. Your job in Module 2 is not to act on it directly. It is to turn
it into a behavioral spec, run an agent against that spec, and see where the looseness
bites.

---

> **From:** Service delivery
> **Subject:** New service address on leaf1
>
> Hey, we're standing up a small internal service that needs to live on `leaf1`.
> Can you put `10.50.0.1/32` on a new loopback on leaf1 and make sure it's
> reachable from the other leaf? Should be quick. Let me know when it's done.

---

Notes you can already see if you look closely:

- "reachable from the other leaf" is the real goal, but it does not say how to
  confirm it, or from where.
- It says nothing about routing: a loopback with an address is not automatically
  reachable from elsewhere in the fabric.
- "Let me know when it's done" invites the agent to decide for itself what "done"
  means.

Take this into [spec-template.md](spec-template.md) and write it up. Or, to see
the drift fast, run the prewritten [solutions/spec-v1-drifting.md](solutions/spec-v1-drifting.md)
first.
