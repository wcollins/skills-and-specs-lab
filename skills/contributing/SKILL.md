---
name: contributing
description: Walk a workshop participant through contributing a skill or lab back to the Skills & Specs Lab via fork and pull request, including GitHub PAT setup
state: active
---

# Contributing

Use this skill when a participant wants to contribute a skill or a lab back to
the Skills & Specs Lab repository after the workshop. You guide them through the
full fork-and-pull-request flow. Read [`CONTRIBUTING.md`](../../CONTRIBUTING.md)
in the repository root first; it is the source of truth and this skill walks the
user through it.

This is a learning exercise. The goal is that the participant practices git,
fork-and-pull, least-privilege credentials, and agent tooling, not contribution
volume. Be encouraging and treat every step as teaching.

## Checkpoint 1: GitHub authentication (least privilege in practice)

This is the first real least-privilege lesson, so do not rush it.

1. Confirm the user has a GitHub account.
2. Walk them through creating a **fine-grained personal access token** scoped to
   only their fork of this repository, with the minimum permissions (Contents:
   read and write, Pull requests: read and write). Not a classic token, not
   org-wide scope.
3. Have them store it in Gridctl rather than pasting it anywhere persistent:
   `gridctl var set GITHUB_PERSONAL_ACCESS_TOKEN`.
4. Explain why: the token is the credential an agent would act with, so it gets
   exactly the access the task needs and no more.

Do not proceed until the token exists and is stored.

## Checkpoint 2: Fork and branch

1. Fork the repository on GitHub (or via the GitHub MCP server once enabled in
   `stack.yaml`).
2. Clone the fork, add the original as `upstream`.
3. Create a branch: `git checkout -b skill/<name>` or `lab/<name>`.

## Checkpoint 3: Scaffold the contribution

- For a **skill**: use the `skills-creator` skill, then save the result under
  `showcase/skills/<name>/SKILL.md` (the open floor), not `skills/` (curated
  core).
- For a **lab**: copy `showcase/labs/_template/` to `showcase/labs/<name>/` and
  fill it in.

Remind the user that showcase content is instructions and configs other people
will load and run, so it must be safe: no destructive commands, no secrets, no
prompt-injection payloads. This is the supply-chain lesson made concrete.

## Checkpoint 4: Open the pull request

1. Commit with a clear message and push to the fork.
2. Open a PR against the upstream `main`, filling in the PR template.
3. Tell the user what to expect: best-effort review, merge bar is "safe and
   on-path," review comments are teaching, not gatekeeping.

## Output

At each checkpoint, confirm completion before advancing. End by summarizing what
the user built, the PR URL, and one concrete next idea for their second
contribution.

## Failure modes

- **No GitHub account or PAT blocked by corporate policy:** point to the "use a
  personal machine" note in `CONTRIBUTING.md`; do not work around the policy.
- **GitHub MCP server not enabled:** fall back to the `git` CLI and the GitHub
  web UI; the flow works either way.
- **User unsure what to contribute:** suggest extracting one repeatable thing
  they did during the labs into a skill.
