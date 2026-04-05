# Automated-IP-Intelligence (Python-Bash)

## Overview
This is an automation project, which uses Linux-native security tool designed to automate the detection and mitigation of brute-force attacks and malicious network activity. By integrating real-time log monitoring with threat intelligence, the aim of this project is to reduce Mean Time to Respond (MTTR) by moving from manual analysis to automated firewall remediation.

### The Reason/Problem (The "Why")
This project was mainly made with the desire to move beyond manual security tasks and build a high-efficiency SOC workflow. In a live environment, a SOC Analyst shouldn't spend their day manually checking every suspicious IP or endlessly scrolling through raw logs to find a needle in a haystack.

I built this tool to address that bottleneck. By combining automated log monitoring, real-time threat intelligence, and firewall orchestration, I’ve created a system that doesn't just alert—it defends. This project represents my shift toward Detection Engineering, where the goal is to automate the 'busy work' so analysts can focus on the high-level threats that actually matter.

While this project focuses on IP-based remediation, it is designed to be the modular foundation for a full-scale automated SOC.

I recognize that a complete security posture requires more than just firewall blocks; it requires a multi-layered defense. This tool is the 'first iteration'—a functional proof-of-concept that proves we can bridge raw telemetry with automated response. From here, the framework is ready to scale into deeper detection engineering, such as email header analysis, SIEM integration (ELK/Wazuh), and more complex 'Human-in-the-Loop' orchestration.

## Architecture & Logic
<img width="774" height="487" alt="image" src="https://github.com/user-attachments/assets/70ad3953-b5c6-4a5f-944e-7798961c5814" />

This is a quick overview of the architecture of the project and what each part does:

**Ingestion (The Lookout):** A Bash-based monitoring agent utilizes tail -F and awk for high-speed string processing of system logs.

**Analysis (The Brain):** A Python engine handles JSON-based API requests to AbuseIPDB, calculating risk scores based on real-world threat telemetry.

**Remediation (The Muscles):** Automated iptables drop-rules are applied to high-risk IPs, with a persistent local blocklist to minimize API latency and preserve credits.

**Persistence:** Managed as a systemd daemon to ensure high availability and automatic recovery across system reboots.

## Try the Porject
If you want to test how well my project works or you just want to use it yourself, feel free to, these are the requirements you might need to fulfill beforing going into it.

Prerequisites:

Linux (Tested on Kali/Ubuntu)

Python 3.x

AbuseIPDB API Key

Installation:

Clone the repository: git clone https://github.com/your-username/Sentinel-IP-Response.git

Install dependencies: pip install requests

Configure your API key in scripts/brain_1.py.

Deploy the service: sudo cp config/defender.service /etc/systemd/system/


## DISCLAIMER
This tool is for educational and defensive purposes. Always ensure you have permission to monitor logs and manage firewall rules on the target system.
