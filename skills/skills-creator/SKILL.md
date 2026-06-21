---
name: skills-creator
description: Scaffold a new agentskills.io SKILL.md from a short description, with the right frontmatter, a focused scope, and a quality checklist
state: active
---

# Skills creator

Use this skill when the user wants to turn a repeatable procedure into a new
agent skill. Your job is to produce a single, well-scoped `SKILL.md` that follows
the [agentskills.io](https://agentskills.io/specification) format and the quality
bar set by the `network-state-query` reference skill in this registry.

## Before you write anything

Ask the user for, or infer from context, these four things. Do not skip this
step. A skill with a fuzzy scope is worse than no skill.

1. **Trigger.** In one sentence, when should an agent reach for this skill?
2. **Scope.** What is explicitly in, and what is explicitly out? A good skill
   does one job. If you find yourself listing three unrelated jobs, that is three
   skills.
3. **Inputs and outputs.** What does the skill need from the user, and what
   structured result does it produce?
4. **Failure modes.** What should the agent do when a precondition is not met
   (tool missing, device unreachable, ambiguous request)? Name the behavior.

If the answer to "should this be a skill?" is unclear, say so. A one-off task
that will not recur does not need a skill. Recognizing over-engineering early is
itself part of the discipline.

## Write the SKILL.md

Produce a directory `<name>/SKILL.md` with this shape:

```markdown
---
name: <kebab-case-name>
description: <one line, starts with a verb, says when to use it>
state: draft
---

# <Title>

<One paragraph: what this skill does and when to use it.>

## Steps
<Numbered, deterministic procedure. Each step is an instruction to the agent.>

## Output
<The exact structure the agent should return.>

## Failure modes
<What to do when each precondition fails.>
```

Rules:

- `name` is kebab-case and matches the directory name.
- `description` starts with a verb and states the trigger, because Gridctl serves
  it as the prompt's one-line summary and that is how the user picks the skill.
- Set `state: draft` on creation. The author activates it deliberately with
  `gridctl activate <name>` once it has been reviewed. Choosing what loads into
  your agent is part of the lesson.
- Least privilege: name only the tools the skill actually needs. Do not invite
  the agent to reach for destructive operations.
- Graceful failure: every skill says what to do when a precondition fails.

## After writing

1. Save to `skills/<name>/SKILL.md` (core, curated) or
   `showcase/skills/<name>/SKILL.md` (community floor), then load it into the
   registry (`./scripts/load-skills.sh` or `gridctl skill add`).
2. Validate: `gridctl skill validate <name>`.
3. Activate when ready: `gridctl activate <name>`.
4. Confirm it appears as a prompt in the connected client.

## Output

Return the full `SKILL.md` content, the path you would save it to, and a
two-line note on the scope decisions you made (what you left out and why).
