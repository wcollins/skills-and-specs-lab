# Troubleshooting

Common failures in the Skills & Specs Lab and how to fix them. Start with the
matrix, then read the remedy for your row below it. For questions rather than
errors, see [`FAQ.md`](FAQ.md). For host setup, see
[`../setup/01-docker-containerlab.md`](../setup/01-docker-containerlab.md).

## Troubleshooting matrix

| Symptom | Likely cause | Quick remedy |
|---------|--------------|--------------|
| `Cannot connect to the Docker daemon` | Docker daemon not running | Start it (on macOS, inside the OrbStack VM: `sudo systemctl start docker`), then re-run. |
| `containerlab: command not found` on macOS | Running on the Mac host, not in the Linux VM | Enter the OrbStack VM: `orb -m clab`. Containerlab does not run natively on macOS. |
| `docker exec clab-skills-specs-lab-*` "no such container" on macOS | Running on the Mac host, not in the OrbStack VM where the fabric lives | Enter the VM: `orb -m clab`. The repo, Docker, the fabric, Gridctl, and your client must all share that one host. |
| SR Linux image pull hangs or fails | Corporate proxy or VPN blocking `ghcr.io` | Confirm the block, pre-pull on an unblocked network, or load the image from a file. |
| Image arch mismatch on pull or start | Wrong architecture variant | Should not happen (the image is multi-arch). Confirm with `docker manifest inspect`. |
| Smoke test reports BGP sessions not established | Fabric still converging | Wait about 30 seconds and re-run, or `./scripts/reset.sh`. |
| `gridctl apply` fails, port 8180 in use | Another process owns port 8180 | Free the port or stop the other gridctl gateway, then re-apply. |
| `gridctl status` shows clab server unhealthy | clab-api not running, or `CLAB_MCP_BIN` not set | Start the clab-api server on port 8080 and point `CLAB_MCP_BIN` at the compiled binary. |
| clab-api login / `inspectLab` returns `401 Invalid username or password` with the documented creds | A running clab-api container is pinned to a stale `/etc/passwd`/`/etc/shadow` inode after the user or password was (re)created | Restart the API server so it re-reads the files: `docker restart clab-api-server`. |
| MCP client does not see any skills | Skills not imported, not `state: active`, or client not linked or restarted | Import them (`gridctl skill add <repo-url> --path skills`, or `./scripts/load-skills.sh` offline), activate the skill, then `gridctl link` and restart the client. |
| `permission denied` running containerlab | Containerlab needs root or rootless Docker | Run with `sudo`, or set up rootless Docker. |
| Containerlab will not run on Windows | WSL2 not enabled | Enable WSL2 and run Docker and Containerlab inside it. |

## Remedies

### Docker not running

Every part of the lab depends on Docker. The workshop installs `docker-ce`
inside the Linux environment where Containerlab runs (the OrbStack VM on macOS,
WSL2 on Windows, the host on Linux), via the Containerlab quick-setup script in
[`../setup/01-docker-containerlab.md`](../setup/01-docker-containerlab.md).
OrbStack's own Docker engine serves the macOS host, not the VM, so it is not
what the lab uses.

Confirm the daemon is up with `docker info`. If it is not running, start it
inside that Linux environment:

```bash
sudo systemctl start docker
```

If `docker` commands give a `permission denied` on the socket instead, your user
is not yet in the `docker` group, see the permission-denied remedy below.

### containerlab "command not found" on macOS

Containerlab needs Linux and does not run natively on macOS. Mac users run
everything inside an OrbStack arm64 Linux VM. Enter it with:

```bash
orb -m clab
```

Then run `./scripts/deploy.sh` and the other scripts from inside the VM. If the
command is still missing inside the VM, re-check the setup guide
([`../setup/01-docker-containerlab.md`](../setup/01-docker-containerlab.md)).

### SR Linux image pull fails behind a corporate proxy or VPN

The image lives at `ghcr.io/nokia/srlinux:25.10.2`. If your network blocks
GitHub Container Registry, the pull stalls or errors. Confirm the block by
trying `docker pull ghcr.io/nokia/srlinux:25.10.2` directly and watching for a
timeout or a TLS or auth error tied to `ghcr.io`. Options: pull on an unblocked
network and `docker save` or `docker load` the image, or ask your network team
to allowlist `ghcr.io`. See the corporate-laptop note in [`FAQ.md`](FAQ.md).

### Image architecture mismatch

This should not happen, because the SR Linux image is multi-arch and arm64
capable. If you suspect an architecture problem, inspect the manifest:

```bash
docker manifest inspect ghcr.io/nokia/srlinux:25.10.2
```

Confirm an `arm64` (or your host's) entry is present. If it is and the start
still fails, the problem is elsewhere (most often Docker not running in the
Linux VM).

### BGP sessions not established in the smoke test

The fabric takes a moment to converge after deploy. If `./scripts/smoke-test.sh`
reports sessions in `active` or `connect` rather than `established`, wait about
30 seconds and run it again. If it still does not converge, reset to known-good:

```bash
./scripts/reset.sh   # destroy and redeploy, ~90s
```

### Gridctl port 8180 already in use

The Gridctl gateway listens on port 8180 (web UI at http://localhost:8180). If
`gridctl apply` fails because the port is taken, find and stop whatever owns it
(often a previous gateway that did not shut down), then re-apply. Use
`gridctl status` to check for an existing gateway first.

### Gridctl clab server shows unhealthy

The clab MCP server depends on two things: a running clab-api server on port
8080, and a self-compiled Go binary that Gridctl launches. The turnkey way to get
both is `./scripts/setup-clab-mcp.sh`, which installs Go if needed, builds the
binary, starts clab-api on :8080, and writes `~/.gridctl/clab-mcp.env`. It is
idempotent, so re-running it is the quickest fix for an unhealthy server. The
usual cause of "clab server unhealthy in gridctl status" is that clab-api is not
running, or that the env file was not sourced so `CLAB_MCP_BIN` and `CLAB_API_URL`
are unset. Run `source ~/.gridctl/clab-mcp.env`, confirm clab-api is up
(`docker ps | grep clab-api-server` and `curl -s http://localhost:8080/`), then
re-run `gridctl apply` and `gridctl status`. Note that this server is
intentionally filtered to read-only tools (authenticate, listLabs, inspectLab);
deploy, destroy, and exec are not exposed by design, so do not expect them.

### clab-api returns 401 with credentials that should be correct

The clab-api server does not have built-in credentials; it authenticates Linux
PAM users. `setup-clab-mcp.sh` creates an `admin` user (default password
`password`) in the `clab_admins` superuser group for this. If a login fails with
`401 Invalid username or password` even though you are using the creds in
`~/.gridctl/clab-mcp.env`, the running container almost certainly has a stale
view of the user database.

Why: `useradd` and `chpasswd` do not edit `/etc/passwd` and `/etc/shadow` in
place; they write a temp file and atomically rename it over the original, which
swaps the file's inode. The clab-api container bind-mounts those two files, and a
container that was already running stays pinned to the *old* inode, so a user or
password created after the container started is invisible to it. A fresh first
run is fine because the user is created before the container mounts the files;
the failure shows up on re-runs and after any password change.

Fix: restart the API server so the bind mounts re-resolve to the current inodes.

```bash
docker restart clab-api-server
curl -s -X POST http://localhost:8080/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"password"}'   # expect a {"token":...} reply
```

`setup-clab-mcp.sh` now does this restart automatically when it finds the
container already running, so re-running the script is also a valid fix. If auth
still fails after a restart, confirm the user exists and is in the superuser
group: `getent passwd admin` and `getent group clab_admins`.

### MCP client does not see skills

Work through these in order:

1. Skills are not in the registry yet. Import them with
   `gridctl skill add https://github.com/wcollins/skills-and-specs-lab --path skills`
   (or `./scripts/load-skills.sh` offline), then `gridctl skill list` to confirm.
2. The skill is not `active`. Gridctl only serves skills with `state: active`.
   Run `gridctl activate <name>`.
3. The client is not linked or has not been restarted. Run `gridctl link
   <client>` and restart the client so it re-reads the available prompts.

### "permission denied" on containerlab

Containerlab needs root privileges, or a rootless Docker setup. Re-run with
`sudo`, or configure rootless Docker so your user can manage containers without
elevation.

### WSL2 not enabled on Windows

Containerlab needs Linux. On Windows that means WSL2. Enable WSL2, install a
Linux distribution, and run Docker and all the lab scripts from inside the WSL2
environment.
