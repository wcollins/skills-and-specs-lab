# What changed between v1 and v2

The whole module turns on two small edits to the spec. The agent, its tools, and
the prompt are identical across both runs. Only the contract changed.

| Section | v1 (drifts) | v2 (holds) |
|---------|-------------|------------|
| Intent | "make it reachable from the other leaf" (goal stated, not enforced) | "reachable from `leaf2` ... advertising it into the fabric underlay" (goal tied to a mechanism) |
| Constraints | "Do not disturb existing interfaces or BGP sessions." | Adds: `lo0.0` **MUST** be in `network-instance default`; all four BGP sessions must stay `established`. |
| Success criteria | "Confirm the new address works." (no location) | "this exact check, run from `leaf2`, returns replies" + "a local ping on `leaf1` is not acceptable proof". |
| Failure modes | "If the address cannot be configured, report the error." | Adds: if the `leaf2` ping fails the change is NOT done; names the likely cause (`lo0.0` not in the routing instance). |

## The two edits that matter

1. **A named routing constraint.** v1 leaves "advertised into the fabric"
   implicit, so the step that places `lo0.0` into `network-instance default` is
   optional, and the agent skips it. v2 makes it a `MUST`, so advertisement is
   mandatory. Without advertisement the accept-all export policy has nothing to
   export, and `leaf2` never gets a route.

2. **A located success check.** v1's "confirm the new address works" does not say
   from where, so the agent picks the check that passes: a local ping on `leaf1`.
   v2 pins the check to `leaf2` and explicitly rejects the local ping as proof, so
   the only way to satisfy the spec is to actually meet the goal.

Everything else, the address, the interface name, the no-regressions rule, is the
same. Two sentences of precision are the difference between an agent that drifts
and one that holds.
