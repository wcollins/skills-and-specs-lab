# 02 - SR Linux image

The fabric runs Nokia SR Linux. Pull the pinned image now so the first
`./scripts/deploy.sh` does not stall on a multi-hundred-megabyte download. The
image is multi-arch and supports `linux/arm64`, so it runs on Apple Silicon
through the OrbStack VM.

Run these commands where Docker lives: inside the OrbStack VM on macOS
(`orb -m clab`), inside WSL2 on Windows, or directly on Linux.

1. Pull the pinned image.

   ```bash
   docker pull ghcr.io/nokia/srlinux:25.10.2
   ```

   `ghcr.io` is GitHub Container Registry. This image is public, so no login is
   required.

2. Confirm Docker selected the right architecture (optional, Apple Silicon).

   ```bash
   docker image inspect ghcr.io/nokia/srlinux:25.10.2 --format '{{.Architecture}}'
   ```

   On Apple Silicon this prints `arm64`.

## Verify this step

```bash
docker image inspect ghcr.io/nokia/srlinux:25.10.2 >/dev/null && echo "image present"
```

This prints `image present`. The setup verifier in guide 05 checks for this exact
pinned tag.

## Troubleshooting

- Pull is slow or times out: the image is large. Retry the `docker pull`; Docker
  resumes completed layers rather than restarting from zero.
- `no matching manifest for linux/arm64`: you are on an older Docker that cannot
  resolve the multi-arch manifest, or you forced a platform. Drop any
  `--platform` flag and let Docker pick, or update Docker (guide 01).
