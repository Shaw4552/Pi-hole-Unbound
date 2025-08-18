Pihole + unbound DNS
we can do this in one go. I’ll draft a README.md for your GitHub that explains your Pi-hole + Unbound setup, how it works, and include a cheat sheet for future iPhone or network testing. You can just save this as README.md in your repo.


# Pi-hole + Unbound Private Recursive DNS Setup

This repository documents my **Pi-hole + Unbound DNS setup**, which provides **private, secure, recursive DNS resolution with DNSSEC validation** for my home network.

---

## Overview

- **Pi-hole** acts as the main DNS server for clients on the network (all VLANs).  
- **Unbound** runs as a local recursive resolver behind Pi-hole (`192.168.10.242`), performing **root-to-authoritative resolution**.  
- Benefits:
  - Ad-blocking at the network level
  - Full recursive resolution (no reliance on third-party DNS)
  - DNSSEC validation (protects against spoofed records)
  - Privacy: no logs sent to public DNS providers

---

## How It Works

1. **Client request**: A device (laptop, phone, IoT, etc.) queries Pi-hole for a domain.
2. **Pi-hole cache**:
   - If domain is cached (including blocklists), it responds immediately.
   - Otherwise, forwards query to Unbound.
3. **Unbound recursive resolution**:
   - Starts at **root servers**.
   - Moves to **TLD servers** (e.g., `.com`, `.org`).
   - Queries the **authoritative server** for the domain.
   - Validates **DNSSEC signatures**.
4. **Response returns**:
   - Pi-hole logs the result.
   - Client receives the answer (A, AAAA, MX, etc.).

---

## Verification & Testing

These tests can be done **from any device using Pi-hole DNS**, including iPhone:

### 1. Check normal resolution
```text
example.com
* Should return multiple A/AAAA records.
* First query may be slower (~300ms) if recursive.
* Subsequent queries will be faster (cached).
2. DNSSEC validation tests
Test Domain	Expected Result	Purpose
sigok.verteiltesysteme.net	Resolves to IP	Confirms DNSSEC-valid domains resolve
sigfail.verteiltesysteme.net	Does NOT resolve (SERVFAIL)	Confirms DNSSEC catches broken signatures
3. Recursion test
* Lookup a never-before-visited domain (e.g., random12345.openai.com).
* First query will take longer (Unbound is walking root → TLD → authoritative).
* Check Pi-hole query log: it should show Forwarded → 192.168.10.242#53.
4. iPhone-specific check
1. Open Settings → Wi-Fi → DNS → ensure Pi-hole IP is used.
2. Use a DNS lookup app (e.g., “DNS Tools”) to query the above domains.
3. Observe latency differences:
    * Cached responses → <5ms
    * Recursive first hits → ~300ms

Best Practices & Notes
* Static IP for Pi-hole and Unbound to avoid DHCP conflicts.
* No external forwarders in Unbound config (use root-hints only).
* Enable DNSSEC validation: harden-dnssec-stripped: yes.
* Optional: add a second Pi-hole for redundancy.
* Monitor Pi-hole query log to see cache hits vs forwarded queries.

Quick iPhone Cheat Sheet
Action	Domain	Expected Result	Notes
Test DNSSEC-valid	sigok.verteiltesysteme.net	Resolves to IP	Should succeed
Test DNSSEC-invalid	sigfail.verteiltesysteme.net	No IP (SERVFAIL)	Confirms validation
Test recursion/cache	example.com	Multiple IPs	First query slower, cached queries fast
Random domain test	random12345.openai.com	Resolves if exists	Shows full recursion
Blocklist test	googleads.g.doubleclick.net	Blocked (0ms)	Should hit Pi-hole cache/block
References
* Pi-hole Documentation
* Unbound Documentation
* DNSSEC Validation Tests
* Best Practices for Recursive DNS

Author: James Shaw Home Lab: Pi-hole + Unbound running on 192.168.10.x network
