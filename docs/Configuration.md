# Configuration Guide

The Appoena Datadog Solaris Agent is configured using a YAML file, named `conf.yaml` the file must be located at
`/etc/appoena/solaris`.

This guide explains each section and configuration option available in the `conf.example.yaml` file.

## General Configuration

These settings control the basic behavior and identity of the agent.

| Option                     | Description                                                                                     | Default           |
|----------------------------|-------------------------------------------------------------------------------------------------|-------------------|
| `api_key`                  | **Required.** Your Datadog API key.                                                             | `""`              |
| `app_key`                  | Your Datadog Application key. Required for some metadata features.                              | `""`              |
| `site`                     | The Datadog site to send data to (e.g., `datadoghq.com`, `datadoghq.eu`).                       | `"datadoghq.com"` |
| `hostname_override`        | Manually set the hostname reported to Datadog.                                                  | *Auto-detected*   |
| `metric_prefix`            | A prefix to add to all metrics reported by the agent (e.g., `solaris.`).                        | `""`              |
| `disable_ssl_verification` | If set to `true`, disables SSL certificate verification for API requests. **Use with caution.** | `false`           |
| `tags`                     | A list of global tags to add to every metric (e.g., `- env:prod`).                              | `[]`              |

---

## Logging

Configure how the agent logs its own activities.

| Option             | Description                                                                       | Default |
|--------------------|-----------------------------------------------------------------------------------|---------|
| `log.level`        | The log level. Options: `debug`, `info`, `warn`, `error`, `fatal`.                | `info`  |
| `log.log_payloads` | If `true`, logs sent payloads to Datadog. Only works when `log.level` is `debug`. | `false` |

---

## Process Collection

Enables monitoring of individual processes and system-wide process states.

| Option                                          | Description                                                                              | Default |
|-------------------------------------------------|------------------------------------------------------------------------------------------|---------|
| `process.enabled`                               | Enables the basic process collector.                                                     | `false` |
| `process.live_process_enabled`                  | Enables the Live Process collector (Live Processes view in Datadog).                     | `false` |
| `process.enable_solaris_process_metrics`        | Enables submission of specific `solaris.process.*` metrics.                              | `false` |
| `process.tag_process_metrics_with_process_name` | Adds the process name as a tag to process metrics.                                       | `false` |
| `process.tag_process_metrics_with_process_pid`  | Adds the PID as a tag to process metrics.                                                | `false` |
| `process.processes_to_monitor`                  | A list of specific process names to monitor. If empty `[]`, all processes are monitored. | `[]`    |
| `process.min_collection_interval`               | Minimum interval (seconds) between process metric collection cycles.                     | `20`    |
| `process.live_process_min_collection_interval`  | Minimum interval (seconds) between live process collection cycles.                       | `5`     |

---

## Network Collection

Monitors network interfaces and throughput.

| Option                            | Description                                                                                                                   | Default |
|-----------------------------------|-------------------------------------------------------------------------------------------------------------------------------|---------|
| `network.enabled`                 | Enables network interface metric collection.                                                                                  | `false` |
| `network.devices`                 | A list of network interface names to monitor (e.g., `net0`). If empty `[]`, all are monitored.                                | `[]`    |
| `network.min_collection_interval` | Minimum interval (seconds) between collection cycles.                                                                         | `20`    |

---

## Memory and Swap Collection

Monitors system RAM and swap space usage.

| Option                           | Description                                           | Default |
|----------------------------------|-------------------------------------------------------|---------|
| `memory.enabled`                 | Enables RAM usage collection.                         | `true`  |
| `memory.swap_enabled`            | Enables swap space usage collection.                  | `true`  |
| `memory.min_collection_interval` | Minimum interval (seconds) between collection cycles. | `20`    |

---

## Filesystem Collection

Monitors disk usage and mount point capacity.

| Option                               | Description                                                         | Default |
|--------------------------------------|---------------------------------------------------------------------|---------|
| `filesystem.enabled`                 | Enables filesystem usage collection.                                | `false` |
| `filesystem.devices`                 | List of block devices to monitor. If empty `[]`, all are monitored. | `[]`    |
| `filesystem.mountPoints`             | List of mount points to monitor. If empty `[]`, all are monitored.  | `[]`    |
| `filesystem.min_collection_interval` | Minimum interval (seconds) between collection cycles.               | `20`    |

---

## CPU and Uptime Collection

Basic system health metrics.

| Option                           | Description                                           | Default |
|----------------------------------|-------------------------------------------------------|---------|
| `cpu.enabled`                    | Enables CPU usage collection.                         | `true`  |
| `cpu.min_collection_interval`    | Minimum interval (seconds) between collection cycles. | `20`    |
| `uptime.enabled`                 | Enables system uptime collection.                     | `true`  |
| `uptime.min_collection_interval` | Minimum interval (seconds) between collection cycles. | `20`    |
