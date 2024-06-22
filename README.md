- [Support UniversalBit Project](https://github.com/universalbit-dev/universalbit-dev/tree/main/support)
- [Disambiguation](https://en.wikipedia.org/wiki/Wikipedia:Disambiguation)

### Intro
---
SELKS is a free and open source Debian-based IDS/IPS/Network Security Monitoring platform 
released under GPLv3 from [Stamus Networks](https://www.stamus-networks.com/). 

### SELKS {404 != 104}
### What is SELKS
---
SELKS is a showcase of what Suricata IDS/IPS/NSM can do and the network protocol monitoring logs and alerts it produces. As such any and all data in SELKS is generated by Suricata: 

required
#### Docker Engine on Ubuntu:
[docker installation](https://docs.docker.com/engine/install/ubuntu/)

* prepare environment
```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```
* run apt installer:
```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

---

### Getting SELKS
---
* SELKS installation
```
git clone https://github.com/StamusNetworks/SELKS.git
cd SELKS/docker/
./easy-setup.sh
sudo -E docker compose up -d
```

SELKS can be installed via docker compose on any Linux or Windows OS. Once installed it is 
ready to use out of the box solution.

* [Suricata IDPS/NSM](https://suricata.io/)
* [Elasticsearch](https://www.elastic.co/products/elasticsearch)
* [Logstash](https://www.elastic.co/products/logstash)
* [Kibana](https://www.elastic.co/products/kibana)
* [Scirius](https://github.com/StamusNetworks/scirius)
* [EveBox](https://evebox.org/)
* [Arkime](https://arkime.com/)
* [CyberChef](https://github.com/gchq/CyberChef)

The acronym was established before the addition of Arkime, EveBox and CyberChef.  

And it includes preconfigured dashboards like this one:



### Resources:
---
* [Docker](https://github.com/StamusNetworks/SELKS/wiki/Docker)
* [AttackDetection](https://github.com/ptresearch/AttackDetection)
* [Snort](https://www.snort.org/)
* [Sslbl](https://sslbl.abuse.ch/)
* [Proofpoint](https://www.proofpoint.com/us)
* [Etnetera](https://www.etnetera.cz/security)
* [Hunting-Rules](https://github.com/travisbgreen/hunting-rules)

### Hardware Requirements: 
---
200GB+ SSD grade is recommended.

### Threat Hunting
---
The usage of Suricata data is further enhanced by Stamus' developed Scirius, a threat hunting interface. The interface is specifically designed for Suricata events and combines a drill down approach to pivot for quick exploration of alerts and NSM events. It includes predefined hunting filters and enhanced contextual views:


### Logs
---
An example subset (not complete) of raw [JSON logs](https://github.com/StamusNetworks/SELKS/tree/master/doc/example-logs) generated by Suricata. 

### Information
---
If you are a new to Suricata, you can [read](https://www.stamus-networks.com/blog/the-other-side-of-suricata) a series of articles we wrote about `The other side of Suricata.

### Dashboards
---
#### SELKS has by default over 28 default dashboards, more than 400 visualizations and 24 predefined searches available.

Here is an extract of the dashboards list: SN-ALERTS, SN-ALL, SN-ANOMALY, SN-DHCP, SN-DNS, SN-DNP3, SN-FILE-Transactions, SN-FLOW, SN-HTTP, SN-HUNT-1, SN-IDS, SN-IKEv2, SN-KRB5, SN-MQTT, SN-NFS, SN-OVERVIEW, SN-RDP, SN-RFB, SN-SANS-MTA-Training, SN-SIP, SN-SMB, SN-SMTP, SN-SNMP, SN-SSH, SN-STATS, SN-TLS, SN-VLAN, SN-TFTP, SN-TrafficID

Additional visualizations and dashboards are also available in the ``Events viewer`` 
* [EveBox](https://evebox.org/)

### Usage and logon credentials
---
You need to authenticate to access to the web interface(see the ``HTTPS access`` section below ). 
##### The default user/password is ``selks-user/selks-user`` (including through the Dashboards or Scirius desktop icons).
You can change credentials and user settings by using the top left menu in Scirius.  


### HTTPS access
---
If you wish to remotely (from a different PC on your network) access the 
dashboards you could do that as follows (in your browser):

* https://your.selks.IP.here/ - Scirius ruleset management and a central point for all dashboards and EveBox

You need to authenticate to access to the web interface. 
* The default user/password is the same as for local access: ``selks-user/selks-user``.
Don't forget to change credentials at first login. You can do that by going to ``Account settings`` in the top left dropdown menu of
Scirius.

### Getting help
---
You can get more information on SELKS [wiki](https://github.com/StamusNetworks/SELKS/wiki)

You can get help about SELKS on our [Discord channel](https://discord.gg/h5mEdCewvn)

If you encounter a problem, you can open a [issue](https://github.com/StamusNetworks/SELKS/issues)

### Broad-Spectrum Threat Detection
---
* Multiple detection mechanisms from machine learning, anomaly detection, and signatures
* High-fidelity “Declarations of Compromise” with multi-stage attack timeline
* Weekly threat intelligence updates from Stamus Labs

### Guided Threat Hunting and Incident Investigation
---
* Advanced guided threat hunting filters
* Host insights tracks over 60 security-related attributes
* Easily convert hunt results into custom detection logic
* Explainable and transparent results with evidence

### Enterprise Scale Management and Integration
---
* Automated classification and alert triage
* Management of multiple probes from single console
* Seamless integration with SOAR, SIEM, XDR, EDR, IR
* Multi-tenant Cloud 
* Configuration backup and restoration 


### More Information about SSP
---
* [Schedule a live demo](https://www.stamus-networks.com/demo) 


