---
name: example-skill
description: Summarize a single piece of fabric state in a structured way, instead of returning a raw tool dump (replace this with your own one-line, verb-first description that says when to use the skill)
state: draft
---

# Example skill

Copy this template to start a showcase skill. Save your copy under
`showcase/skills/<your-name>/SKILL.md`, set `name` to a kebab-case slug that
matches the directory, and rewrite `description` as a single line that starts
with a verb and says when an agent should reach for this skill. Keep
`state: draft` for a contribution; the importer activates it.

Replace this paragraph with one or two sentences on what the skill does and when
to use it. Name the operational question it answers. Skills earn their place by
asking a question directly and returning a scoped, labeled result, instead of
handing back a raw tool dump.

Study [`../../../skills/network-state-query/SKILL.md`](../../../skills/network-state-query/SKILL.md)
for the quality bar before you write your own.

## Steps

1. State the first concrete action the agent takes (for example, validate the
   input against a known set, and stop if it is invalid).
2. Describe each read or query, with the exact command where it helps. Use the
   read-only clab tools (authenticate, listLabs, inspectLab) and the sanctioned
   scripts. Do not deploy or destroy the fabric from a skill.
3. Describe how to parse or reduce what you got back. Do not paste raw output;
   extract the fields the output section defines.

## Output

Define exactly what the skill returns so the result is predictable. Prefer a
fixed structure (for example, a small JSON object with named fields) over prose.
Note which field a human reads first.

```json
{
  "subject": "<what was queried>",
  "result": "<the reduced answer>",
  "ok": true,
  "summary": "One line a human reads first."
}
```

## Failure modes

- **Invalid input:** describe what the skill returns when the input is not
  recognized (for example, an error plus the list of valid values).
- **Resource not available:** describe what to return when the thing being
  queried is not running or not reachable, and give a hint at the fix.
- **Ambiguous or partial state:** describe how to report a result that is not a
  clean success, and what the agent should suggest next.
