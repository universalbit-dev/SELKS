# SELKS 
[Getting Started](https://docs.clearndr.io/docs/start/getting-started)

SELKS is a free, open-source Debian-based IDS/IPS/Network Security Monitoring (NSM) platform released under GPLv3 by Stamus Networks. SELKS showcases Suricata's IDS/IPS/NSM capabilities with integrated tooling and prebuilt dashboards to accelerate threat hunting, alerting and investigation.

This enhanced quick-start consolidates prerequisites, installation steps, verification, common operations, security guidance, troubleshooting and links to resources.

---



## At-a-glance
- Purpose: Demonstrate Suricata event collection, alerting and hunting with preconfigured dashboards and tools.
- Main components: Suricata → logs (EVE JSON) → ELK stack (Elasticsearch, Logstash, Kibana) + Scirius (hunt/rules), EveBox (events viewer), Arkime (pcap/index), CyberChef, additional utilities.
- License: GPLv3 (SELKS)
- Recommended minimum hardware (for small lab demo): 200 GB SSD, 8+ GB RAM, 2+ CPU cores. For production or larger data volumes, provision more CPU/RAM/IO (16+ GB RAM, NVMe, cluster Elasticsearch).

---

## Prerequisites

1. A Linux host (Ubuntu is common) or Windows with WSL2 (for Docker Desktop).
2. Docker Engine and Docker Compose (or Docker Compose plugin).
   - On Ubuntu, follow Docker's official install: https://docs.docker.com/engine/install/ubuntu
   - Quick install snippet (run with care):
     ```
     sudo apt-get update
     sudo apt-get install ca-certificates curl
     sudo install -m 0755 -d /etc/apt/keyrings
     sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
     sudo chmod a+r /etc/apt/keyrings/docker.asc
     echo \
       "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
       $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
       sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
     sudo apt-get update
     sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
     ```
3. Network and disk capacity: plan for 200GB+ SSD (or more depending on retention) and stable network connectivity.

---

## Get SELKS

Clone the repository and run the provided setup helpers:

```
git clone https://github.com/StamusNetworks/SELKS.git
cd SELKS/docker/
./easy-setup.sh
sudo -E docker compose up -d
```

Notes:
- The `easy-setup.sh` script helps prepare environment variables and certificates. Review it before running in production.
- On systems with `docker-compose` binary rather than plugin, you may need `docker-compose up -d` instead of `docker compose up -d`.

---

## Default credentials and access

- Default local web user: selks-user
- Default password: selks-user

Important:
- Change the default password at first login.
- Scirius (rules management) is usually the central login entry. See the web UI for account settings. If you expose the UI externally, secure it behind TLS and a reverse proxy or VPN.

---

## Where to navigate (web UI)

Open a browser to:
- https://<your.selks.IP.here>/ — Main portal (Scirius + links to Kibana/EveBox/Arkime)
- Kibana dashboards, EveBox and Arkime are reachable from Scirius or via their respective URLs. Exact ports and paths can vary by the compose setup; check docker-compose.yml for current mappings.

To discover service ports:
```
cd SELKS/docker
grep -E "ports:|container_name|image:" -n docker-compose.yml -n
sudo docker compose ps
```

---

## Quick verification

1. Confirm containers are up:
```
sudo docker compose ps
```

2. View logs (example for Elastic and Scirius):
```
sudo docker compose logs -f elasticsearch
sudo docker compose logs -f scirius
```

3. Validate Suricata EVE logs (if Suricata is feeding data):
- Check EVE JSON files or Logstash input streams configured in the compose stack.

---

## Common tasks

- Restart all services:
  ```
  sudo docker compose down
  sudo docker compose up -d
  ```

- Update SELKS (pull latest and restart)
  ```
  cd SELKS
  git pull
  cd docker
  ./easy-setup.sh   # re-run if there are new env changes
  sudo -E docker compose pull
  sudo -E docker compose up -d
  ```

- Backup critical data
  - Elasticsearch: use snapshot/restore (configure a snapshot repository for safe backups).
  - Scirius: export rules and account settings from UI; locate persistent volumes in docker-compose and snapshot them.
  - Arkime: export configuration and capture indexes.

- Restore: follow the component-specific restore procedures (Elasticsearch snapshots, Arkime backup/restore, Scirius import).

---

## Security best practices

- Immediately change default credentials.
- Limit management interfaces (Kibana, Scirius, EveBox, Arkime) to trusted networks or behind VPNs.
- Use TLS for all services exposed outside the host. Review `easy-setup.sh` for certificate creation and customization.
- Keep Docker and images up to date; regularly pull upstream images and test upgrades in staging.
- Harden Elasticsearch (user auth, TLS, secure settings) if exposed.

---

## Troubleshooting tips

- Container fails to start or exits
  - Check logs with `sudo docker compose logs <service>`.
  - Confirm host has sufficient memory and disk.
  - If Elasticsearch fails due to memory or mmap issues, ensure vm.max_map_count is set:
    ```
    sudo sysctl -w vm.max_map_count=262144
    # persist by adding to /etc/sysctl.conf: vm.max_map_count=262144
    ```

- Kibana or dashboards show no data
  - Ensure Suricata is generating EVE JSON logs and that Logstash/Logforwarder is ingesting them.
  - Check Elasticsearch indices: `curl -s 'http://localhost:9200/_cat/indices?v'` (or use container exec if bound to localhost).
  - Recreate index templates if mappings mismatch.

- Elasticsearch cluster health is yellow/red
  - Inspect disk space, JVM heap settings, and logs inside the elasticsearch container.
  - For single-node demos, ensure minimum_master_nodes (or equivalent) is configured correctly for your ES version.

---

## Frequently Asked Questions (FAQ)

Q: Can I run SELKS on Windows?
A: Yes via Docker Desktop on Windows (WSL2). For best performance use a Linux host or VM.

Q: How long do logs persist?
A: Retention depends on Elasticsearch sizing and retention policy. Configure ILM (Index Lifecycle Management) for automated retention and rollover.

Q: Where are dashboards and visualizations?
A: Prebuilt dashboards are provided (e.g., SN-ALERTS, SN-HTTP). You can find and import additional dashboards via Kibana or Scirius links.

Q: How do I add more Suricata probes?
A: For multiple probes, forward their EVE JSON to centralized Logstash/Elasticsearch (over AMQP, Filebeat, syslog or direct HTTP) and configure indexing patterns. SELKS is often used as a central server with distributed Suricata sensors.

---

## Resources & links

- SELKS (GitHub): https://github.com/StamusNetworks/SELKS
- Suricata (IDS/IPS/NSM): https://suricata.io/
- Elasticsearch: https://www.elastic.co/products/elasticsearch
- Kibana: https://www.elastic.co/products/kibana
- Logstash: https://www.elastic.co/products/logstash
- Scirius (Suricata rule manager): https://github.com/StamusNetworks/scirius
- EveBox (event viewer): https://evebox.org/
- Arkime (packet capture & indexing): https://arkime.com/
- CyberChef: https://github.com/gchq/CyberChef
- SELKS Wiki: https://github.com/StamusNetworks/SELKS/wiki
- SELKS Discord (community help): https://discord.gg/h5mEdCewvn

---

## Contributing & getting help

- Open issues: https://github.com/StamusNetworks/SELKS/issues
- Before opening an issue: search the wiki and issues; include logs, docker-compose output and steps to reproduce.
- For interactive help, join the Discord channel.

---

## Final notes & suggestions

- Treat SELKS as an excellent lab/demo platform. If you plan to run for long-term monitoring or production, invest time in sizing Elasticsearch, securing the stack, configuring backups and enabling proper retention/ILM.
- Review configuration files in SELKS/docker/ (especially docker-compose.yml and environment files) before exposing services to your network.

---
