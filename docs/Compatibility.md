# Compatibility Matrix

The Appoena Solaris Agent is designed to operate in restricted
enterprise environments with minimal dependencies.

## Supported Operating Systems

| OS      | Version     | Status    |
|---------|-------------|-----------|
| Solaris | 10          | Supported |
| Solaris | 11          | Supported |

## Required Runtime

| Component | Version |
|-----------|---------|
| Java      | 8       |
| jq        | 1.5+    |
| unzip     | any     |

## Required Utilities

The following utilities must be available in PATH:

- `java`
- `jq`
- `unzip`

## Filesystem Requirements

The agent requires:

- read access to system telemetry sources
- write access to a directory inside the installation path

Example:

/etc/appoena/solaris
├ run/ (write permissions required)

## System Utilities Requirements

- `hostname`
- `uname`
- `uptime`
- `df`
- `zpool`
- `swap`
- `ipmpstat`
- `kstat`


## Network Requirements

Outbound connectivity to Datadog endpoints configured by the customer.

No connections are made to Appoena's infrastructure.

## Unsupported Environments

- hosts without Java 8
- systems where unzip or jq are unavailable
- restricted environments preventing execution of shell scripts