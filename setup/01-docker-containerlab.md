# 01 - Docker and Containerlab

Containerlab orchestrates the SR Linux fabric, and it runs containers, so you
need Docker too. Containerlab does not run natively on macOS, because macOS is
not Linux and lacks the kernel network namespaces Containerlab depends on. Pick
the section that matches your host.

- macOS (Apple Silicon): install OrbStack, create a Linux VM, and run Docker and
  Containerlab inside it.
- Linux: install Docker and Containerlab natively.
- Windows: use WSL2 with Ubuntu and follow the Linux steps inside it.

## macOS (Apple Silicon)

OrbStack gives you a fast, native arm64 Linux VM. OrbStack's own Docker engine
serves the macOS host, not the VM, so you install Docker and Containerlab
*inside* the VM. Everything in this workshop (Docker, Containerlab, the fabric,
and `verify-setup.sh`) runs inside the VM, not on macOS directly.

1. Install OrbStack.

   ```bash
   brew install orbstack
   ```

2. Create the Linux VM named `clab` on Debian. Debian's codename is a stable
   release that Docker's apt repo supports, so the Docker install in step 4 just
   works.

   ```bash
   orb create debian clab
   ```

   If you already created a `clab` VM (for example a default Ubuntu one), delete
   it first so the name is free: `orb delete clab`.

3. Enter the VM. Run the remaining steps in this guide inside it.

   ```bash
   orb -m clab
   ```

4. Inside the VM, install Docker and Containerlab in one step. Containerlab's
   quick-setup script with the `all` target installs `docker-ce`, docker
   compose, and Containerlab together.

   ```bash
   curl -sL https://containerlab.dev/setup | sudo -E bash -s "all"
   sudo usermod -aG docker "$USER"
   ```

   Log out of the VM and back in (`exit`, then `orb -m clab`) so the `docker`
   group membership takes effect.

The image runs as `linux/arm64` on Apple Silicon, which the pinned SR Linux
image supports (guide 02).

## Linux

1. Install Docker and Containerlab in one step. The quick-setup script's `all`
   target installs `docker-ce`, docker compose, and Containerlab together.

   ```bash
   curl -sL https://containerlab.dev/setup | sudo -E bash -s "all"
   sudo usermod -aG docker "$USER"
   ```

   Log out and back in so the `docker` group applies. (On a bleeding-edge,
   non-LTS distro where the Docker repo step fails, install Docker your distro's
   way first, then run the script with `install-containerlab` instead of `all`.)

## Windows

Install WSL2 with Ubuntu, open the Ubuntu shell, and follow the Linux section
above inside it. Everything for the workshop lives inside WSL2.

## Verify this step

Run both checks. On macOS, run them inside the OrbStack VM (`orb -m clab`).

```bash
docker run --rm hello-world
containerlab version
```

The first command prints a "Hello from Docker!" message. The second prints a
Containerlab version banner.

## Troubleshooting

- `permission denied` talking to the Docker socket: your user is not yet in the
  `docker` group, or the session predates the group change. Log out and back in
  (on macOS, `exit` the VM and re-enter with `orb -m clab`), then retry.
- `containerlab: command not found` on macOS: you are at the macOS prompt, not
  inside the VM. Containerlab lives in the OrbStack Linux VM. Enter it with
  `orb -m clab` and try again.
