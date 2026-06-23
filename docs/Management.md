## Helper Scripts

The agent includes several helper scripts located in `/etc/appoena/solaris/scripts/` to simplify management. If you used
the automated installer, these are available in your `PATH`.

| Script                     | Description                                   |
|----------------------------|-----------------------------------------------|
| `solaris-agent-enable.sh`  | Enables and starts the SMF service.           |
| `solaris-agent-stop.sh`    | Temporarily stops the SMF service.            |
| `solaris-agent-disable.sh` | Permanently disables the SMF service.         |
| `solaris-agent-logs.sh`    | Displays the SMF service logs in the console. |

---

## Service Management (SMF)

The agent runs as a Solaris SMF service with the FMRI: `svc:/appoena/solaris_agent:default`.

- **Check Status**: `svcs solaris_agent`
- **Enable Service**: `svcadm enable solaris_agent`
- **Disable Service**: `svcadm disable solaris_agent`
- **Restart Service**: `svcadm restart solaris_agent`
- **Troubleshoot**: `svcs -xv solaris_agent`

---

## Logs and Diagnostics

Service logs are managed by SMF. You can view them using the helper script:

```bash
solaris-agent-logs.sh
```

Or manually:

```bash
svcs -L solaris_agent | xargs tail -f
```
