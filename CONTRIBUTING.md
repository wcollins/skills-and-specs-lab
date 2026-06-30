# Contributing to Skills & Specs Lab

This is the contribution guide for the Skills & Specs Lab, Part 1 of the Packt
workshop *Engineering Agentic Network Operations*. Contributing happens after
the workshop, asynchronously, through fork and pull request. You do not need a
GitHub account, a fork, or a personal access token to run the workshop itself.
You only need them to contribute back.

There is a `contributing` skill in this repo
([`skills/contributing/SKILL.md`](skills/contributing/SKILL.md)) that walks you
through everything below interactively, including the personal access token
step. Use it if you would rather be guided. This file is the source of truth;
the skill follows it.

## The two-tier model

This repo has two homes for skills and labs, and it matters which one you
contribute to.

- `skills/` is the curated core. These skills load into every student's
  registry, so they must stay deterministic and on-path. You do not open PRs
  directly into core.
- `showcase/` is the open community floor. It has `showcase/skills/` and
  `showcase/labs/`. This is where your contributions go. Anyone can import a
  showcase skill into their own Gridctl stack.

A strong showcase skill can later be promoted into core by a maintainer. That
promotion is the maintainer's call, not something you request in a PR. Aim for
"safe and on-path" first.

See [`showcase/README.md`](showcase/README.md) for what the showcase is and how
others import what you build.

## Where your contribution goes

- A skill goes under `showcase/skills/<name>/SKILL.md`, never under core
  `skills/`.
- A lab goes under `showcase/labs/<name>/` (a directory with at least a
  `README.md`).

## The contribution flow

### 1. Create a GitHub account

If you do not already have one, create a GitHub account. That is all this step
needs.

### 2. Create a fine-grained personal access token (PAT)

This is the first least-privilege lesson, made concrete. Create a
**fine-grained** PAT (not a classic token), scoped to only your fork of this
repository, with the minimum permissions:

- Contents: read and write
- Pull requests: read and write

Nothing else. A PAT is the credential an agent would act with on your behalf, so
it should have exactly the access the task needs and no more.

Store the token with Gridctl rather than pasting it into a file, a shell
history, or an environment file that persists:

```bash
gridctl var set GITHUB_PERSONAL_ACCESS_TOKEN
```

### 3. Fork, clone, and add upstream

Fork the repository on GitHub. Clone your fork, then add the original repository
as the `upstream` remote so you can keep in sync:

```bash
git clone https://github.com/<you>/skills-and-specs-lab.git
cd skills-and-specs-lab
git remote add upstream https://github.com/<upstream-owner>/skills-and-specs-lab.git
```

### 4. Branch

Use a branch name that names what you are adding:

```bash
git checkout -b skill/<name>     # for a skill
git checkout -b lab/<name>       # for a lab
```

### 5. Scaffold the contribution

- For a skill, use the `skills-creator` skill
  ([`skills/skills-creator/SKILL.md`](skills/skills-creator/SKILL.md)), then
  save the result under `showcase/skills/<name>/SKILL.md`. You can also copy
  [`showcase/skills/_template/SKILL.md`](showcase/skills/_template/SKILL.md) as
  a starting point.
- For a lab, copy
  [`showcase/labs/_template/`](showcase/labs/_template/README.md) to
  `showcase/labs/<name>/` and fill in the README.

Skills use the [agentskills.io](https://agentskills.io/specification)
`SKILL.md` format: YAML frontmatter with `name` (kebab-case), a one-line
`description` that starts with a verb and says when to use the skill, and an
optional `state:` field (`draft`, `active`, or `disabled`). Only `active` skills
are served by Gridctl. Submit showcase skills as `state: draft`; a reviewer or
the importer decides when to activate.

### 6. Commit, push, and open a PR

Commit with a clear message, push to your fork, and open a pull request against
upstream `main` using the template below.

```bash
git push -u origin skill/<name>
```

Then open the PR on GitHub and fill in the template.

## Pull request template

Copy this into your PR description:

```markdown
## What this adds
<!-- One or two sentences. A showcase skill or lab, and what it does. -->

## Type
- [ ] Showcase skill (`showcase/skills/<name>/SKILL.md`)
- [ ] Showcase lab (`showcase/labs/<name>/`)

## Where it lives
<!-- Path(s) added. Confirm it is under showcase/, not core skills/. -->

## Safe content checklist
- [ ] No destructive commands (no teardown, wipe, or force-delete of anything a reader runs).
- [ ] No secrets or credentials (no real tokens, keys, or passwords beyond the lab default admin / admin).
- [ ] No prompt-injection payloads or instructions aimed at the reader's agent.
- [ ] No network calls to untrusted endpoints.
- [ ] Stays on-path: uses the read-only clab tools and the sanctioned scripts, does not deploy or destroy the fabric from an agent.

## Tested
<!-- How you ran it. For a skill: did `gridctl skill validate <name>` pass? For a lab: did you walk the steps end to end? -->
```

## Safe content rules

Showcase skills are instructions loaded into other people's agents, and showcase
labs are configs other people will run. Treat your contribution like code other
people will execute, because that is what it is. Contributions must follow these
rules:

- No destructive commands.
- No secrets or credentials.
- No prompt-injection payloads.
- No network calls to untrusted endpoints.

A maintainer does a light skim for prompt-injection and destructive content
before merging. Keeping your contribution obviously safe makes that skim fast.

For the importer's side of this (review before you import), see the disclaimer
in [`showcase/README.md`](showcase/README.md).

## What to expect from review

Review is best-effort. There is no SLA, and there is no CI you need to keep
green. The merge bar is "safe and on-path." Review comments are teaching
moments, not gatekeeping. Occasionally a strong skill is promoted into core or
highlighted.

## If your environment blocks contributing

If corporate policy blocks personal access tokens, forks, or GitHub access on
your work machine, the honest fallback is to do the contribution step on a
personal machine. Do not work around your employer's policy.
