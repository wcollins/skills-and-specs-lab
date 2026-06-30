# Nokia SR Linux Cheat Sheet — Skills & Specs Lab

---

## Getting onto a node

```bash
# From the Containerlab host (the OrbStack Linux VM on macOS):
ssh admin@clab-skills-specs-lab-leaf1     # by container name, password: admin
ssh admin@172.20.20.21                    # or by mgmt IP (leaf1)

# Drop straight into the CLI without a shell:
docker exec -it clab-skills-specs-lab-leaf1 sr_cli

# Management IPs:  spine1 .11  spine2 .12  leaf1 .21  leaf2 .22  (172.20.20.0/24)
```

---

## CLI modes & navigation

| Command | What it does |
|---|---|
| `enter candidate` | Enter candidate (config edit) mode |
| `enter running` | Back to running mode (live config view) |
| `enter state` | Read-only state/telemetry tree |
| `discard now` / `discard stay` | Throw away candidate edits (exit / keep editing) |
| `commit now` | Apply candidate and return to running |
| `commit stay` | Apply candidate but stay in candidate mode |
| `commit validate` | Dry-run validate candidate without applying |
| `commit confirmed` | Apply; auto-revert in 5 min unless re-confirmed |
| `back` / `exit` / `exit all` | Up one level / out / to root |
| `tree` | Show the schema tree at the current context |
| `pwc` | Print the current working context (where am I) |
| `?` (Tab) | Context help / completion |

---

## Showing config (the lab's `set` syntax)

```bash
# Flat "set" lines — this is exactly how the lab configs/*.cli files read:
info flat /interface ethernet-1/1
info flat /network-instance default protocols bgp

# Hierarchical (indented) view:
info /interface system0
info /network-instance default protocols bgp

# Full running config as set-commands:
info flat | more

# Only what differs from factory defaults:
info from running flat | more
```

---

## Interfaces

```bash
show interface                      # summary of all interfaces
show interface ethernet-1/1         # one fabric link
show interface ethernet-1/1.0       # the subinterface (L3)
show interface system0.0            # the loopback (system0)
show interface ethernet-1/1 detail

# State tree equivalents (enter state first, or use 'from state'):
info from state /interface ethernet-1/1 statistics
info from state /interface ethernet-1/1 ethernet
```

Lab interface map (per node, type `ixr-d2l`):

| Node | e1-1 | e1-2 | system0 (loopback) | AS |
|---|---|---|---|---|
| spine1 | 10.1.1.1/30 → leaf1 | 10.1.2.1/30 → leaf2 | 10.0.0.1/32 | 65100 |
| spine2 | 10.2.1.1/30 → leaf1 | 10.2.2.1/30 → leaf2 | 10.0.0.2/32 | 65100 |
| leaf1  | 10.1.1.2/30 → spine1 | 10.2.1.2/30 → spine2 | 10.0.0.101/32 | 65101 |
| leaf2  | 10.1.2.2/30 → spine1 | 10.2.2.2/30 → spine2 | 10.0.0.102/32 | 65102 |

---

## BGP (the eBGP underlay)

```bash
show network-instance default protocols bgp summary          # neighbor table
show network-instance default protocols bgp neighbor         # all neighbors
show network-instance default protocols bgp neighbor 10.1.1.1 detail

# Routes learned / advertised on a session:
show network-instance default protocols bgp neighbor 10.1.1.1 received-routes ipv4
show network-instance default protocols bgp neighbor 10.1.1.1 advertised-routes ipv4

# BGP RIB:
show network-instance default protocols bgp routes ipv4 summary
```

Expected on a converged fabric:
- Each **leaf** has **2** BGP sessions (one to each spine), both `established`.
- Each **spine** has **2** BGP sessions (one to each leaf), both `established`.
- Every node's RIB carries all four `/32` loopbacks (`10.0.0.1/2/101/102`).

---

## Routing table / FIB

```bash
show network-instance default route-table ipv4-unicast summary
show network-instance default route-table ipv4-unicast prefix 10.0.0.102/32
info from state /network-instance default route-table ipv4-unicast route 10.0.0.102/32
```

---

## Making a change (candidate workflow)

```bash
enter candidate
    set / interface ethernet-1/1 description "to-spine1"
    set / network-instance default protocols bgp group spines admin-state enable
    commit validate            # optional dry run
    diff                       # show pending candidate vs running
    commit now
```

> **Lab rule:** do **not** re-deploy the topology from an agent. `deploy.sh` is the
> only sanctioned path to the known-good fabric. Candidate edits for exercises are
> fine; use `./scripts/reset.sh` to get back to known-good (~90s).

---

## System / platform / health

```bash
show version                                  # SR Linux version (expect 25.10.2)
show platform                                 # chassis / type ixr-d2l
show system aaa authentication                # admin-user, auth config
show network-instance default protocols
info from state /system information           # uptime, version, last-booted
show system lldp neighbor                     # verify physical topology wiring
```

---

## Output modifiers (pipe)

```bash
show interface | grep ethernet-1
info flat /network-instance default | more
show network-instance default protocols bgp summary | as json     # JSON output
show interface ethernet-1/1 | as table
```

`| as json` is handy when an agent/skill needs to parse output structurally
rather than scraping text.

---

## Containerlab lifecycle (run on the host, not the node)

```bash
sudo containerlab deploy  -t lab-environment/topology.clab.yml      # bring fabric up
sudo containerlab inspect -t lab-environment/topology.clab.yml      # list nodes + IPs
sudo containerlab destroy -t lab-environment/topology.clab.yml      # tear down

# Lab wrappers (preferred):
./scripts/deploy.sh        ./scripts/smoke-test.sh
./scripts/reset.sh         ./scripts/destroy.sh        ./scripts/checkpoint.sh
```

---

## Quick troubleshooting

| Symptom | Check |
|---|---|
| BGP session not `established` | `show ...bgp neighbor <ip> detail` → look at last-event / peer-as |
| Interface down | `show interface ethernet-1/x` → `oper-state`, then check `admin-state enable` on iface **and** subinterface **and** ipv4 |
| Loopback not advertised | confirm `system0.0` is in `network-instance default` and `accept-all` export policy is applied to the group |
| Can't see a remote `/32` | `show ...route-table ... prefix 10.0.0.x/32`, then check the advertising neighbor's `advertised-routes` |
| Wrong neighbor wiring | `show system lldp neighbor` vs the interface map above |
