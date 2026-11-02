# Automated IP Intelligence (Bash + Python)

SOC analysts shouldn't spend their day pasting IPs into reputation sites. I built a small Linux daemon that follows a log, checks each new source IP against AbuseIPDB, and drops high-risk ones at the firewall automatically.

<img width="1444" height="720" alt="VideoSnap_Python_Video" src="https://github.com/user-attachments/assets/a168030c-2a33-40c4-b628-4155d1c9885c" />

## Demo run

| IP read from log | AbuseIPDB score | Action |
|---|---|---|
| 136.227.180.156, 144.56.235.1, 114.33.60.233, 88.218.47.203 | Allowed |
| 195.88.57.172, 100.200.204.194 | Blocked (iptables DROP) |

## How it works

![Architecture diagram](https://github.com/user-attachments/assets/70ad3953-b5c6-4a5f-944e-7798961c5814)

1. **Watch:** `defender.sh` follows a log with `tail -F` and extracts the source IP with `awk`.
2. **Check:** `brain.py` asks AbuseIPDB for the IP's abuse confidence score (0–100).
3. **Block:** a score of 50 or higher adds an `iptables` DROP rule and records the IP in `blocklist.txt`.
4. **Stay up:** runs as a `systemd` service that restarts on failure and starts at boot.

**Design choices:** IPs already blocked or already checked are skipped, to save API quota. Loopback and the host's own IP are never blocked, so the tool can't lock itself out. The script uses `set -euo pipefail`, and the API call has a timeout so a slow response can't hang the loop.

## Limitations

- **Reputation-based, not brute-force detection (yet).** It doesn't count failed logins; it checks every new IP it sees.
- IPv4 only, one log file, fixed threshold of 50.
- [Tested against a generated log, not live traffic. Edit to match what you actually did.]
- No automated tests.

## Quick start

```bash
git clone https://github.com/Saim6526/Automated-IP-Intelligence_Python-Bash
cd Automated-IP-Intelligence_Python-Bash
pip install requests
export ABUSEIPDB_KEY="your-key"
sudo -E ./scripts/defender.sh /path/to/logfile
```

To run it as a service, edit the paths in `scripts/defender.service`, copy it to `/etc/systemd/system/`, then `sudo systemctl enable --now defender`.

## Next up

1. **Real brute-force logic:** count failures per IP in a time window and only look up IPs over a threshold.
2. **Persistence:** re-apply the blocklist at startup, or use `ipset`.
3. **Input validation:** check every IP before it reaches `iptables`.
4. **SIEM link:** send block events into the ELK lab from my other projects.

*For educational and defensive use only. Only run it on systems you have permission to monitor.*
