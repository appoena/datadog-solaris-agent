# Appoena Datadog Solaris Agent

The Appoena Datadog Solaris Agent gathers critical system performance metrics and submits them to Datadog.

## Quick Links

* [Submitted Datadog Telemetry](./docs/Submitted%20Datadog%20Telemetry.md)
* [Configuration Guide](./docs/Configuration.md)
* [Manual Installation Guide](./docs/Manual%20Installation.md)
* [Management Guide](./docs/Management.md)
* [ChangeLog](CHANGELOG.md)
* [Compatibility Guide](./docs/Compatibility.md)

## Features

- **Metrics Collection**: Robust collection of Solaris-specific metrics using native tools and Java-based collectors.
- **Datadog Integration**: Direct submission of metrics to Datadog sites (`datadoghq.com`, `datadoghq.eu`, etc.).
- **SMF Support**: Fully integrated with Solaris Service Management Facility (SMF) for lifecycle management (start, stop, restart, auto-recovery).
- **Easy Installation**: Automated installation script that handles dependency checks, filesystem preparation, and SMF manifest import.
- **Lightweight**: Optimized for low resource consumption on Solaris hosts.


## Security Design

The agent operates with the following constraints:

- No outbound communication except configured Datadog endpoints
- No access to customer application data
- Write access limited to its internal working directory

## Quickly Installation

### Prerequisites
- **Solaris 11+**: With SMF (Service Management Facility).
- **Java Runtime Environment (JRE) 8+**: Must be available on the system `PATH`.
- **Root Privileges**: Required for installation and agent execution.

See the [Compatibility Guide](./docs/Compatibility.md) for more details.

To install the latest version of the agent, run:

```bash
curl -sSL "https://github.com/appoena/datadog-solaris-agent/releases/latest/download/install.sh" -o /tmp/install.sh && sudo bash /tmp/install.sh
```
For sh only hosts run:
```bash
curl -sSL "https://github.com/appoena/datadog-solaris-agent/releases/latest/download/install-sh.sh" -o /tmp/install.sh && sudo sh /tmp/install.sh
```

### What the Installer Does:
1. Validates the environment and installs dependencies (`jq`, `unzip`) if missing.
2. Downloads the agent release bundle from GitHub.
3. Prepares the filesystem:
   - Base Directory: `/etc/appoena/solaris`
   - Scripts Directory: `/etc/appoena/solaris/scripts`
   - Manifest Directory: `/var/svc/manifest/appoena`
4. Deploys the agent JAR and helper scripts.
5. Adds the scripts directory to the system `PATH` via `/etc/profile.d/appoena-solaris.sh`.
6. Imports the SMF manifest to register the service.


For manual configuration, see the [Manual Installation Guide](./docs/Manual%20Installation.md).

## Configuration

The agent reads its configuration from `/etc/appoena/solaris/conf.yaml`.

1. Create the configuration file from the example:
   ```bash
   sudo cp /etc/appoena/solaris/conf.example.yaml /etc/appoena/solaris/conf.yaml
   ```

2. Edit the file and provide your Datadog API Key:
   ```yaml
   api_key: "YOUR_DATADOG_API_KEY"
   site: "datadoghq.com"
   tags:
     - "env:production"
     - "host:solaris-01"
   ```
Checkout [Configuration Guide](./docs/Configuration.md) for more details about the configuration options of the agent.


## Uninstall 

To uninstall the agent, run:

```bash
curl -sSL "https://github.com/appoena/datadog-solaris-agent/releases/latest/download/uninstall.sh" -o /tmp/uninstall.sh && sudo bash /tmp/uninstall.sh
```

For sh only hosts use:

```bash
curl -sSL "https://github.com/appoena/datadog-solaris-agent/releases/latest/download/uninstall-sh.sh" -o /tmp/uninstall-sh.sh && sudo sh /tmp/uninstall-sh.sh
```

## License

Use of this software is governed by the EULA included with this repository.
This project is proprietary and closed source. See the [LICENSE](LICENSE) file for more details.

## Distribution

Authorized customers may download release archives from this repository.

## Support

All issues must be submitted using the repository issue templates.
All support requests must be submitted through GitHub Issues. 

Issues opened without using the official templates may be closed
without review.

This policy ensures requests contain enough information to
properly diagnose installation, compatibility, and operational
issues.