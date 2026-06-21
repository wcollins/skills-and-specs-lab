# Setup

This is the setup path for the Skills & Specs Lab, Part 1 of the Packt workshop
"Engineering Agentic Network Operations". Work through the five guides below in
order. Target time is under 30 minutes on a machine that already has Homebrew
(macOS) or a normal package manager (Linux / WSL2).

Before you start, know which host path applies to you:

- macOS (Apple Silicon): Containerlab does not run natively on macOS, so you
  will install OrbStack and run everything inside an arm64 Debian Linux VM. Guide
  01 covers this.
- Linux: install Docker and Containerlab natively.
- Windows: use WSL2 with Ubuntu and follow the Linux path inside WSL2.

Provisional hardware floor (to be confirmed after dry runs): about 8 GB of free
RAM and about 10 GB of free disk. The four SR Linux nodes are light.

## Guides, in order

1. [01 - Docker and Containerlab](01-docker-containerlab.md): install the
   container runtime and the lab orchestrator (plus the OrbStack VM on macOS).
2. [02 - SR Linux image](02-srlinux-image.md): pull the pinned Nokia SR Linux
   image the fabric runs on.
3. [03 - API keys](03-api-keys.md): authenticate your LLM client (Claude Code is
   the worked example; any MCP client works).
4. [04 - Gridctl](04-gridctl.md): install the Gridctl MCP gateway, load the core
   skills, and link your client. Optionally build the Containerlab MCP server.
5. [05 - Verification](05-verification.md): run `./scripts/verify-setup.sh` and
   confirm you are ready.

When guide 05 reports all required checks passed, skim
[GETTING-STARTED.md](../GETTING-STARTED.md) and you are ready for the workshop.
