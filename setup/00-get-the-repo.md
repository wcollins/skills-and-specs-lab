# 00 - Get the repo

Everything in this workshop runs from a clone of this repository. Get it onto the
machine you will work on before anything else.

## Where to clone it (read this first on macOS)

On macOS the repo, Docker, Containerlab, Gridctl, and your MCP client must all
live in the **same** Linux environment, which is the OrbStack VM. So clone the
repo **inside** the VM, not on the macOS host.

- macOS (Apple Silicon): finish OrbStack and the `clab` VM first (guide
  [01](01-docker-containerlab.md)), then come back and clone from **inside** the
  VM (`orb -m clab`). A clone on the Mac host is not reachable from the fabric or
  the gateway.
- Linux: clone anywhere in your home directory.
- Windows: clone inside your WSL2 Linux home directory, not the Windows
  filesystem.

If you have not set up the Linux environment yet, that is fine. Read this page,
do guide 01, then clone in the right place.

## Clone

```bash
git clone https://github.com/wcollins/skills-and-specs-lab.git
cd skills-and-specs-lab
```

Every command in the rest of the setup and in the labs is run from this
directory (the repo root). When a guide says "from the repo root", this is it.

No `git`, or GitHub is blocked on your network? Download the ZIP from the
repository's GitHub page ("Code" -> "Download ZIP"), unpack it inside the same
Linux environment, and `cd` into the unpacked directory.

## If the workshop has a pinned tag

For a live cohort, the instructor may pin a release tag so everyone runs the
exact same revision (e.g. `workshop-2026-06`). If you were given one in the
pre-work email, check it out after cloning:

```bash
git checkout <tag>     # e.g. git checkout workshop-2026-06
```

No tag in your email means `main` is correct.

## Verify this step

```bash
ls scripts/verify-setup.sh
```

It prints the path with no error. You are in the repo root and ready for guide
[01](01-docker-containerlab.md).
