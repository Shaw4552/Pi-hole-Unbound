# VLAN DNS Testing Checklist

Use this checklist to verify DNS resolution via Pi-hole + Unbound on each VLAN.

---

## 🔎 VLAN Details

- **VLAN Name**: `Media`
- **VLAN ID**: `55`
- **Subnet**: `192.168.55.0/24`
- **Device IP**: `192.168.55.127`
- **Device Hostname**: `joshs-MacBook-Pro.local`

---

## ✅ Test Results
🌐 VLAN / IP Verification
→ Current IP: 	inet 192.168.55.127 netmask 0xffffff00 broadcast 192.168.55.255
→ Detected VLAN (from IP): 55

🔍 VLAN DNS Test - alt.lan
------------------------------
Using Pi-hole IP: 192.168.10.2

1️⃣  Testing DNS server assignment...
→ System DNS: 192.168.10.2
✅ Correct DNS IP

2️⃣  dig example.com
23.220.75.245
23.192.228.84
23.192.228.80
23.215.0.138
23.215.0.136
23.220.75.232

3️⃣  DNSSEC Valid Test (sigok)

; <<>> DiG 9.10.6 <<>> +dnssec sigok.verteiltesysteme.net
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 33012
;; flags: qr rd ra; QUERY: 1, ANSWER: 4, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags: do; udp: 1232
;; QUESTION SECTION:
;sigok.verteiltesysteme.net.	IN	A

;; ANSWER SECTION:
sigok.verteiltesysteme.net. 60	IN	CNAME	sigok.rsa2048-sha256.ippacket.stream.
sigok.verteiltesysteme.net. 60	IN	RRSIG	CNAME 13 3 1799 20250904000000 20250814000000 47187 verteiltesysteme.net. lUuzZ0xTqX+O9K1WHX0WDx1zbMgFUwihgbGk8+ymfgREJo7+q0TR2ERQ ZPWN395KUv1JwP5Q7lrzV24lLJL2ww==
sigok.rsa2048-sha256.ippacket.stream. 60 IN A	195.201.14.36
sigok.rsa2048-sha256.ippacket.stream. 60 IN RRSIG A 8 4 60 20250910030002 20250731030002 46436 rsa2048-sha256.ippacket.stream. ri+84VM1ehEwqTlHbhKjPU+lYyK5B2K+4ADCDNvRy7eaphEK4UIi75NT g54x0dwISSa+R6KOYXwUz8RjXbVdg4FtLaQX77kbB4a6KNg5PwvrP6Bn rL2n3QT8i1y086eFDxvPAneefA8gTE8GpOgZkimDceSBfIy9RpZROCQi +4ZbShvpx9JE30aydGiyNbicVtm1UBLZ0NJqy7f8jDJW8teXFcKYBTgq n/YROH4UIK8k0O/zP7jjL1/3v7yl1xp6uJ8vFAWjPYrt3lkQ4etRPIiU ZIihyhDRWlqGTH/dEvSllK5bYT5kDez4sEL6sXdspQpgqdqPzjvRqgt7 xlEkYg==

;; Query time: 516 msec
;; SERVER: 192.168.10.2#53(192.168.10.2)
;; WHEN: Wed Aug 27 08:03:00 CDT 2025
;; MSG SIZE  rcvd: 555


4️⃣  DNSSEC Invalid Test (sigfail)

; <<>> DiG 9.10.6 <<>> +dnssec sigfail.verteiltesysteme.net
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: SERVFAIL, id: 3897
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags: do; udp: 1232
;; QUESTION SECTION:
;sigfail.verteiltesysteme.net.	IN	A

;; Query time: 532 msec
;; SERVER: 192.168.10.2#53(192.168.10.2)
;; WHEN: Wed Aug 27 08:03:01 CDT 2025
;; MSG SIZE  rcvd: 57

✅ Should see no output (SERVFAIL)

5️⃣  Recursive query test (random domain)
;; Query time: 130 msec
;; SERVER: 192.168.10.2#53(192.168.10.2)
;; WHEN: Wed Aug 27 08:03:01 CDT 2025
;; MSG SIZE  rcvd: 134


6️⃣  Blocklist test (googleads)
142.250.113.157
142.250.113.156
142.250.113.154
142.250.113.155
✅ Should return 0.0.0.0 or nothing
