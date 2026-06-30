# Quick reference

The commands you use most, in one place. On macOS, run all of these inside the
OrbStack VM (`orb -m clab`).

## Lifecycle and safety

```bash
./scripts/deploy.sh          # boot the SR Linux fabric (never run by an agent)
./scripts/smoke-test.sh      # confirm interfaces up + BGP established
./scripts/reset.sh           # back to known-good in ~90s (the live escape hatch)
./scripts/checkpoint.sh      # validate midpoint state; add --restore to repair
./scripts/destroy.sh         # tear the fabric down
```

## Gridctl stack and skills

```bash
gridctl apply stack.yaml                 # bring up the gateway + clab MCP server
gridctl status                           # gateway and clab server health
gridctl link claude-code                 # wire your MCP client to the gateway
gridctl skill list                       # list skills (SOURCE shows git or local)
gridctl skill validate <name>            # check a skill before activating
gridctl activate <name>                  # serve a draft skill as an MCP prompt
./scripts/load-skills.sh                 # offline fallback: copy skills into registry
```

## Fabric checks (the ones the labs use)

```bash
# Lab 1c: add a loopback to leaf1, then break and undo an interface
docker exec clab-skills-specs-lab-leaf1 sr_cli -ec \
  "set / interface system0 subinterface 0 ipv4 address 10.0.0.201/32" "commit now"
docker exec clab-skills-specs-lab-leaf1 sr_cli -ec \
  "set / interface ethernet-1/1 admin-state disable" "commit now"   # break
docker exec clab-skills-specs-lab-leaf1 sr_cli -ec \
  "set / interface ethernet-1/1 admin-state enable" "commit now"    # undo

# Lab 2: the local ping (passes for the wrong reason) vs the real check
docker exec clab-skills-specs-lab-leaf1 sr_cli "ping network-instance default 10.50.0.1 -c 2"
docker exec clab-skills-specs-lab-leaf2 sr_cli "ping network-instance default 10.50.0.1 -c 2"
```

## Fabric facts

- Nodes: `spine1`, `spine2`, `leaf1`, `leaf2` (Nokia SR Linux, type `ixr-d2l`).
- Container names: `clab-skills-specs-lab-<node>`.
- Credentials: `admin` / `admin`. Loopbacks on `system0.0`, advertised into BGP.
- Each leaf peers with both spines: 2/2 BGP sessions established is healthy.
- Where your built skills live: `~/.gridctl/registry/skills/<name>/SKILL.md`.

## When something is wrong

More than one checkpoint behind, or the fabric looks wrecked? Do not debug it
live. Run `./scripts/reset.sh` (about 90 seconds) and keep going. Your built
skills in the registry survive a fabric reset. For specific errors, see
[troubleshooting.md](troubleshooting.md).
