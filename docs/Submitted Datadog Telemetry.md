# Submitted Datadog Telemetry

This document lists the telemetry emitted to Datadog by each collector (metrics, service checks, and metadata payloads).

## CPU Metrics

| Metric              | Type  | Unit    | Tags |
|---------------------|-------|---------|------|
| `system.cpu.user`   | gauge | percent | none |
| `system.cpu.system` | gauge | percent | none |
| `system.cpu.idle`   | gauge | percent | none |
| `system.cpu.iowait` | gauge | percent | none |
| `system.cpu.steal`  | gauge | percent | none |
| `system.load.1`     | gauge | load    | none |
| `system.load.5`     | gauge | load    | none |
| `system.load.15`    | gauge | load    | none |

---

## FileSystem Metrics

| Metric               | Type  | Unit         | Tags                                                                                 |
|----------------------|-------|--------------|--------------------------------------------------------------------------------------|
| `system.disk.total`  | gauge | bytes        | `device:<volume>`, `device_label:<deviceName>`, optionally `filesystem:<mountPoint>` |
| `system.disk.used`   | gauge | bytes        | `device:<volume>`, `device_label:<deviceName>`, optionally `filesystem:<mountPoint>` |
| `system.disk.free`   | gauge | bytes        | `device:<volume>`, `device_label:<deviceName>`, optionally `filesystem:<mountPoint>` |
| `system.disk.in_use` | gauge | ratio (0..1) | `device:<volume>`, `device_label:<deviceName>`, optionally `filesystem:<mountPoint>` |

---

## IO Metrics

All metrics include tag: `device:<diskName>`.

| Metric               | Type  | Unit             | Tags                |
|----------------------|-------|------------------|---------------------|
| `system.io.rkb_s`    | gauge | KB/s             | `device:<diskName>` |
| `system.io.wkb_s`    | gauge | KB/s             | `device:<diskName>` |
| `system.io.r_s`      | gauge | ops/s            | `device:<diskName>` |
| `system.io.w_s`      | gauge | ops/s            | `device:<diskName>` |
| `system.io.await`    | gauge | ms/op            | `device:<diskName>` |
| `system.io.avg_q_sz` | gauge | queue length     | `device:<diskName>` |
| `system.io.util`     | gauge | percent (0..100) | `device:<diskName>` |

---

## Memory Metrics

| Metric                  | Type  | Unit         | Tags |
|-------------------------|-------|--------------|------|
| `system.mem.total`      | gauge | bytes        | none |
| `system.mem.used`       | gauge | bytes        | none |
| `system.mem.free`       | gauge | bytes        | none |
| `system.mem.usable`     | gauge | bytes        | none |
| `system.mem.pct_usable` | gauge | ratio (0..1) | none |

---

## Swap Metrics

### Global Swap Metrics

| Metric                 | Type  | Unit         | Tags |
|------------------------|-------|--------------|------|
| `system.swap.total`    | gauge | bytes        | none |
| `system.swap.used`     | gauge | bytes        | none |
| `system.swap.free`     | gauge | bytes        | none |
| `system.swap.pct_free` | gauge | ratio (0..1) | none |

### Per-device Swap Metrics

| Metric                     | Type  | Unit  | Tags                                  |
|----------------------------|-------|-------|---------------------------------------|
| `system.swap.device.total` | gauge | bytes | `device:<path>`, `encrypted:<yes/no>` |
| `system.swap.device.used`  | gauge | bytes | `device:<path>`, `encrypted:<yes/no>` |
| `system.swap.device.free`  | gauge | bytes | `device:<path>`, `encrypted:<yes/no>` |

---

## Process Metrics

### Per-process metrics

Tags may include:

- `process_name:<name>` (if enabled)
- `pid:<pid>` (if enabled)

| Metric                                   | Type  | Unit    | Tags                                    |
|------------------------------------------|-------|---------|-----------------------------------------|
| `system.processes.cpu.pct`               | gauge | percent | optional `process_name`, optional `pid` |
| `system.processes.mem.rss`               | gauge | bytes   | optional `process_name`, optional `pid` |
| `system.processes.mem.vms`               | gauge | bytes   | optional `process_name`, optional `pid` |
| `system.processes.threads`               | gauge | count   | optional `process_name`, optional `pid` |
| `system.processes.open_file_descriptors` | gauge | count   | optional `process_name`, optional `pid` |

### Counts by state

| Metric                    | Type  | Unit  | Tags            |
|---------------------------|-------|-------|-----------------|
| `system.processes.number` | gauge | count | `state:<running |sleeping|stopped|zombie|waiting|other>` |

### State metrics and state-specific counts

| Metric                      | Type  | Unit         | Tags                                                  |
|-----------------------------|-------|--------------|-------------------------------------------------------|
| `system.processes.state`    | gauge | enum ordinal | `state:<STATE>` (plus optional `process_name:<name>`) |
| `system.processes.running`  | gauge | count        | for RUNNING                                           |
| `system.processes.waiting`  | gauge | count        | for WAITING                                           |
| `system.processes.sleeping` | gauge | count        | for SLEEPING                                          |
| `system.processes.stopped`  | gauge | count        | for STOPPED                                           |
| `system.processes.zombie`   | gauge | count        | for ZOMBIE                                            |
| `system.processes.other`    | gauge | count        | for OTHER                                             |
| `solaris.process.running`   | gauge | count        | optional (RUNNING)                                    |
| `solaris.process.waiting`   | gauge | count        | optional (WAITING)                                    |
| `solaris.process.sleeping`  | gauge | count        | optional (SLEEPING)                                   |
| `solaris.process.stopped`   | gauge | count        | optional (STOPPED)                                    |
| `solaris.process.zombie`    | gauge | count        | optional (ZOMBIE)                                     |
| `solaris.process.other`     | gauge | count        | optional (OTHER)                                      |

---

### Live Processes

**Telemetry:** Protobuf Payload (to Process Intake)

The agent can be configured to send a full list of running processes as a protobuf payload, similar to the Datadog Process Agent. This includes detailed information about each process (command line, user, etc.) and is sent to the `/api/v1/collector` endpoint.

---

## Network Metrics

All metrics include tag: `device:<interfaceName>`.

| Metric                         | Type  | Unit      | Tags                     |
|--------------------------------|-------|-----------|--------------------------|
| `system.net.bytes_rcvd`        | gauge | bytes/s   | `device:<interfaceName>` |
| `system.net.bytes_sent`        | gauge | bytes/s   | `device:<interfaceName>` |
| `system.net.packets_in.count`  | gauge | packets/s | `device:<interfaceName>` |
| `system.net.packets_out.count` | gauge | packets/s | `device:<interfaceName>` |
| `system.net.packets_in.error`  | gauge | errors/s  | `device:<interfaceName>` |
| `system.net.packets_out.error` | gauge | errors/s  | `device:<interfaceName>` |

### Network interface service check

Service check name: `solaris.net.interface`

| Service Check           | Status | Meaning                               | Tags                                            |
|-------------------------|-------:|---------------------------------------|-------------------------------------------------|
| `solaris.net.interface` |      0 | Interface healthy (up)                | `device:<interfaceName>`, `status:<statusName>` |
| `solaris.net.interface` |      0 | Interface healthy (dormant)           | `device:<interfaceName>`, `status:<statusName>` |
| `solaris.net.interface` |      1 | Interface warning (unknown)           | `device:<interfaceName>`, `status:<statusName>` |
| `solaris.net.interface` |      1 | Interface warning (not present)       | `device:<interfaceName>`, `status:<statusName>` |
| `solaris.net.interface` |      1 | Interface warning (testing)           | `device:<interfaceName>`, `status:<statusName>` |
| `solaris.net.interface` |      2 | Interface critical (down)             | `device:<interfaceName>`, `status:<statusName>` |
| `solaris.net.interface` |      2 | Interface critical (lower layer down) | `device:<interfaceName>`, `status:<statusName>` |

---

### IPMP Status Checks

| Service Check                    | Status | Meaning                                     | Tags                                               |
|----------------------------------|-------:|---------------------------------------------|----------------------------------------------------|
| `solaris.ipmp.group.status`      |      0 | IPMP group healthy (ok)                     | `ipmp_group:<group>`, `ipmp_group_name:<name>`     |
| `solaris.ipmp.group.status`      |      1 | IPMP group warning (degraded)               | `ipmp_group:<group>`, `ipmp_group_name:<name>`     |
| `solaris.ipmp.group.status`      |      2 | IPMP group critical (failed/offline/etc.)   | `ipmp_group:<group>`, `ipmp_group_name:<name>`     |
| `solaris.ipmp.interface.status`  |      0 | IPMP interface healthy (ok)                 | `interface:<iface>`, `ipmp_group:<grp>`, `active:` |
| `solaris.ipmp.interface.status`  |      1 | IPMP interface warning (offline)            | `interface:<iface>`, `ipmp_group:<grp>`, `active:` |
| `solaris.ipmp.interface.status`  |      2 | IPMP interface critical (failed)             | `interface:<iface>`, `ipmp_group:<grp>`, `active:` |

---

## Uptime Metrics

| Metric          | Type  | Unit    | Tags |
|-----------------|-------|---------|------|
| `system.uptime` | gauge | seconds | none |

---

## ZPool Check

| Service Check          | Status | Tags          | Message           |
|------------------------|-------:|---------------|-------------------|
| `solaris.zpool.health` |      0 | `pool:<name>` | `ZPool healthy`   |
| `solaris.zpool.health` |      1 | `pool:<name>` | `ZPool warning`   |
| `solaris.zpool.health` |      2 | `pool:<name>` | `ZPool crirtical` |

## Host Status Checks

| Service Check         | Status | Tags              | Message               |
|-----------------------|-------:|-------------------|-----------------------|
| `solaris.host.status` |      0 | `host:<hostname>` | `Solaris Host check`  |
| `datadog.agent.up`    |      0 | `host:<hostname>` | `Solaris Agent check` |

---

## System Info

Sends host/system inventory-style information periodically.

| Payload      | Type     | Collected Data                                                                                             |
|--------------|----------|------------------------------------------------------------------------------------------------------------|
| `systemInfo` | metadata | Hostname, Host ID, CPU (model, cores, frequency), Memory (total, swap), Platform (OS version, kernel), FS. |