# Showcase

The showcase is the open community floor of the Skills & Specs Lab, Part 1 of
the Packt workshop *Engineering Agentic Network Operations*. It holds skills and
labs that workshop participants contribute and share after the workshop.

- `showcase/skills/` holds community skills, each as `<name>/SKILL.md`.
- `showcase/labs/` holds community labs, each as a `<name>/` directory with a
  `README.md`.

This is the counterpart to the curated core in the repo's top-level `skills/`.
Core skills load into every student's registry and must stay deterministic. The
showcase is open: anyone can contribute here, and anyone can import what others
contribute into their own Gridctl stack. A strong showcase skill can be promoted
into core by a maintainer.

The deliberate choice of what you load into your agent is itself part of the
lesson. The showcase exists so you practice that choice with real community
content.

## Safety disclaimer

Review any community skill or lab before you import or run it.

Showcase skills are instructions that get loaded into your agent, and showcase
labs are configs that you will run. Community content is agent-loaded
instructions, so treat importing a skill the same way you would treat running
someone else's code. This is the supply-chain lesson of the workshop, made
concrete: an unsafe skill in your registry can steer your agent the same way a
malicious dependency can steer your build.

Before you import or run anything from the showcase, read it and confirm it
contains:

- No destructive commands.
- No secrets or credentials.
- No prompt-injection payloads (instructions aimed at your agent rather than at
  you).
- No network calls to untrusted endpoints.

The maintainer does a light skim for prompt-injection and destructive content
before merging a contribution, but that skim is best-effort and is not a
substitute for your own review. You own what you load into your agent.

## How to import a showcase skill

Importing a showcase skill into your own registry is two steps: add, then
activate.

1. Add the skills from a git repo into your local registry. This is the
   importer for both your own fork and the upstream repo:

   ```bash
   gridctl skill add <your-fork-or-the-upstream-repo-url>
   ```

2. List what landed and read it before serving it:

   ```bash
   gridctl skill list
   gridctl skill validate <name>
   ```

   Open the `SKILL.md` and review it against the safety disclaimer above.

3. Activate it so Gridctl serves it as an MCP prompt. Skills ship as
   `state: draft` and are not served until you activate them:

   ```bash
   gridctl activate <name>
   ```

To remove a skill from your registry later:

```bash
gridctl skill remove <name>
```

## Contributing to the showcase

Contributions go through fork and pull request, after the workshop. Skills are
saved under `showcase/skills/<name>/SKILL.md` (not core `skills/`), and labs
under `showcase/labs/<name>/`. Start from the templates:

- [`skills/_template/SKILL.md`](skills/_template/SKILL.md)
- [`labs/_template/README.md`](labs/_template/README.md)

The full flow, the pull request template, and the safe-content rules are in
[`../CONTRIBUTING.md`](../CONTRIBUTING.md). The
[`contributing`](../skills/contributing/SKILL.md) skill walks you through it
interactively.
