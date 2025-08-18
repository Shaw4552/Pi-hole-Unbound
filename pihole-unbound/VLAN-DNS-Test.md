VLAN DNS Testing Checklist

Use this checklist to verify DNS resolution via Pi-hole + Unbound on each VLAN. Perform these tests from a device in each VLAN (starting with admin laptop).

Test Info

Device VLAN: ____________

Device IP: ______________

Hostname: ______________

✅ Tests
1. Confirm DNS Server

 DNS is set to 192.168.10.2 (Pi-hole)

2. Basic Resolution
dig example.com


Returns valid A records

Query time under ~150ms

3. DNSSEC Test (Valid)
dig sigok.verteiltesysteme.net +dnssec


Resolves correctly

RRSIG present in the answer

4. DNSSEC Test (Invalid)
dig sigfail.verteiltesysteme.net +dnssec


Fails with SERVFAIL

5. Recursive Resolution Test
dig random12345.openai.com


First query slower (~100–300ms)

Second query faster (~<10ms)

6. Blocklist Test
dig googleads.g.doubleclick.net


Returns 0.0.0.0, NXDOMAIN, or similar block response

🧪 Confirm via Pi-hole Web Interface

Query logs show forwarding to 192.168.10.242#53 (Unbound)

Queries appear from correct client IP / hostname

Notes

Run from macOS Terminal or Linux shell.

dig is preinstalled on macOS/Linux. Windows users may need to install BIND tools or use nslookup (limited).

⚙️ Quick Test Script (macOS/Linux)

Save this as dns-test.sh, make it executable with:

chmod +x dns-test.sh


Run with:

./dns-test.sh

#!/bin/bash

PIHOLE_IP="192.168.10.2"
UNBOUND_IP="192.168.10.242"

echo "🔍 VLAN DNS Test - $(hostname)"
echo "------------------------------"
echo "Using Pi-hole IP: $PIHOLE_IP"
echo

echo "1️⃣  Testing DNS server assignment..."
dns_ip=$(scutil --dns | grep "nameserver\[[0-9]*\]" | head -n 1 | awk '{print $3}')
echo "→ System DNS: $dns_ip"
if [[ "$dns_ip" == "$PIHOLE_IP" ]]; then
  echo "✅ Correct Pi-hole DNS assigned"
else
  echo "❌ Unexpected DNS IP"
fi
echo

echo "2️⃣  dig example.com"
dig example.com +short
echo

echo "3️⃣  DNSSEC Valid Test (sigok)"
dig sigok.verteiltesysteme.net +dnssec +short
echo

echo "4️⃣  DNSSEC Invalid Test (sigfail)"
dig sigfail.verteiltesysteme.net +dnssec +short
echo "✅ Should see no output (SERVFAIL)"
echo

echo "5️⃣  Recursive query test (random domain)"
dig random12345.openai.com +stats | grep "Query time"
sleep 1
dig random12345.openai.com +stats | grep "Query time"
echo

echo "6️⃣  Blocklist test (googleads)"
dig googleads.g.doubleclick.net +short
echo "✅ Should return 0.0.0.0 or nothing"