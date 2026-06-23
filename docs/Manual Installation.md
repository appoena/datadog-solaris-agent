## Fully Manual Installation

1. **Download the Release**:
   Download `solaris-agent.zip` from the [GitHub Releases](https://github.com/appoena/datadog-solaris-agent/releases) page.

2. **Prepare Directories**:
```bash
   sudo mkdir -p /tmp/appoena
   sudo mkdir -p /etc/appoena/solaris/scripts
   sudo mkdir -p /etc/appoena/solaris/run
   sudo mkdir -p /var/svc/manifest/appoena
```

3. **Extract and Deploy**:
```bash
   sudo unzip solaris-agent.zip -d /tmp/appoena
   sudo cp /tmp/appoena/agent.jar /etc/appoena/solaris/
   sudo cp /tmp/appoena/run.sh /etc/appoena/solaris/
   sudo cp /tmp/appoena/scripts/*.sh /etc/appoena/solaris/scripts/
   sudo chmod +x /etc/appoena/solaris/run.sh
   sudo chmod +x /etc/appoena/solaris/scripts/*.sh
   sudo cp /tmp/appoena/conf.example.yaml /etc/appoena/solaris/conf.yaml
   sudo cp /tmp/appoena/solaris_agent.xml /var/svc/manifest/appoena/
```

4. **Import the SMF Manifest**:
```bash
   sudo svccfg import /var/svc/manifest/appoena/solaris_agent.xml
```

5. **Configure the Agent**:
   Edit `/etc/appoena/solaris/conf.yaml` before starting the service.