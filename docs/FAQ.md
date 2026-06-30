# FAQ

Frequently asked questions for the Skills & Specs Lab, Part 1 of the Packt
workshop *Engineering Agentic Network Operations*. If you hit an error rather
than a question, start with [`troubleshooting.md`](troubleshooting.md).

## What are the minimum hardware requirements?

Provisional: about 8 GB of RAM and 10 GB of free disk. These numbers are to be
finalized after dry runs, so treat them as a floor, not a guarantee. The fabric
is four Nokia SR Linux nodes plus the Gridctl gateway, which is modest, but
Docker and (on macOS) the OrbStack Linux VM add overhead.

## Does it run on Apple Silicon?

Yes. Containerlab does not run natively on macOS, so Mac users run everything
inside an OrbStack arm64 Debian Linux VM and enter it with `orb -m clab`. The SR Linux
image `ghcr.io/nokia/srlinux:25.10.2` is arm64-capable, so there is no emulation
penalty on Apple Silicon. See
[`../setup/01-docker-containerlab.md`](../setup/01-docker-containerlab.md).

## Does it run on Windows?

Yes, but you need WSL2 enabled. Docker and Containerlab run inside the WSL2
Linux environment. If WSL2 is not enabled, see the troubleshooting matrix.

## Do I need an Anthropic API key or a Claude subscription?

Claude Code is the worked example throughout the workshop, so you need a way to
run it: either a Claude subscription or an Anthropic API key (the API key path
has usage cost). The skills and the gateway are not Claude-specific, though. The
gateway speaks MCP, so the lab is portable to other MCP clients via
`gridctl link`.

## Do I need a GitHub account or a personal access token?

Not for the workshop. You only need a GitHub account and a fine-grained personal
access token to contribute skills or labs back afterward. The `contributing`
skill ([`../skills/contributing/SKILL.md`](../skills/contributing/SKILL.md))
walks you through account setup, token creation, and the fork-and-pull flow when
you are ready. See [`../CONTRIBUTING.md`](../CONTRIBUTING.md) for the full
process.

## I attended (or did not attend) the first workshop. Does that matter?

This lab is standalone. It assumes only MCP basics, not prior attendance. Part 2
(a different instructor) builds on these ideas and covers agentic loops,
OpenClaw, and NetClaw, but you do not need Part 2 to complete Part 1, and you do
not need any earlier session to start here. If Part 2 ends up needing setup
beyond Part 1, it will be listed in
[`part-2-prerequisites.md`](part-2-prerequisites.md).

## New to MCP? Where do I catch up?

The lab assumes only MCP basics. If you want a quick grounding before the
session, these are enough:

- Model Context Protocol overview and concepts: <https://modelcontextprotocol.io>
- The Containerlab MCP server this lab filters to read-only:
  <https://github.com/FloSch62/clab-mcp-server>
- Gridctl, the MCP gateway and skill registry:
  <https://github.com/gridctl/gridctl>
- The `SKILL.md` skill format the workshop uses:
  <https://agentskills.io/specification>

## Can I use an LLM client other than Claude Code?

Yes, via `gridctl link`. The gateway exposes the skills and tools over MCP, so
any MCP-aware client can use them. One alternate client path is tested; others
are best-effort. Claude Code is the path the lab guides are written against, so
expect the smoothest experience there.

## I am on a locked-down corporate laptop. What goes wrong?

A few common ones, with honest workarounds:

- Docker Desktop licensing. Some organizations restrict Docker Desktop. OrbStack
  or Podman are workable alternatives; OrbStack is the recommended path on macOS
  anyway.
- Proxy or VPN blocking `ghcr.io`. If your network blocks GitHub Container
  Registry, the SR Linux image pull fails. See the troubleshooting matrix for
  how to confirm this and what to try.
- Personal access token policy. If your organization blocks fine-grained tokens
  or forks, you cannot complete the contribution step on the work machine. The
  honest fallback is to do that step on a personal machine. Do not work around
  the policy.

If the corporate environment blocks the workshop itself (not just contributing),
running on a personal machine is the reliable path.
