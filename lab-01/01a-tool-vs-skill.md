# Lab 1a: Raw tool vs skill, side by side

Goal: feel the difference between calling a tool and invoking a skill. Same
underlying question, two very different experiences.

## The question

"Is `leaf1` healthy right now?"

## Path 1: the raw tool

The clab MCP server in your stack exposes a read-only `inspectLab` tool. Ask your
client to call it against the lab and show you the result.

Prompt your client:

> Use the clab `inspectLab` tool to inspect the `skills-specs-lab` lab and show me the raw result.

> **No clab MCP server?** It is optional (set it up any time with
> `./scripts/setup-clab-mcp.sh`). Without it, get the same raw view by running the
> underlying command yourself — this is exactly the kind of unscoped output a raw
> tool returns:
>
> ```bash
> containerlab inspect -t lab-environment/topology.clab.yml --format json
> ```

Observe what comes back: a generic blob describing every node in the lab,
container status, management addresses, kinds. It is accurate, but it is a
firehose. It does not answer "is leaf1 healthy?" It tells you leaf1's container is
running, nothing about interfaces or BGP, and it makes you do the interpretation.

This is what a tool is: exposed capability. Useful, unopinionated, and unscoped.

## Path 2: the skill

Now invoke the `network-state-query` skill (it appears as a prompt in your
client) for `leaf1`.

Prompt your client:

> Run the network-state-query skill for leaf1.

Observe what comes back: a scoped, structured answer. Named interfaces with oper
state, BGP neighbors with session state, a single `healthy` boolean, and a
one-line summary a human reads first. It answers the question you actually asked.

This is what a skill is: a tool's capability wrapped in semantic structure,
scope, and a defined output.

## Checkpoint

You should now see, side by side:

- The raw output (from `inspectLab`, or the `containerlab inspect` fallback):
  broad, generic, container-level, unstructured for your question.
- The `network-state-query` output: narrow, device-level, structured, with a
  `healthy` verdict and a human summary.

Write down one sentence: what did the skill add that the raw tool did not? You
will build exactly that structure yourself in 1b.

## Why this matters

A tool answers "what can I do?" A skill answers "how do we do this job here, and
what does a good answer look like?" As workflows grow, the second question is the
one that scales. If you set up the clab MCP server, note also what you did not
have to worry about: it is filtered to read-only tools, so there was no
`deployLab` or `destroyLab` in reach to call by accident. Least privilege,
expressed in `stack.yaml`, not in a warning.
