#!/bin/bash

echo ""  
echo "🌐 VLAN / IP Verification" 

# Get the first active, non-loopback IP correctly
current_ip=$(ifconfig | grep -w inet | grep -v 127.0.0.1 | awk '{print
$2}' | head -n1)
  
echo "→ Current IP: $current_ip"

# Extract 3rd octet to guess VLAN
vlan_id=$(echo "$current_ip" | cut -d '.' -f 3)
echo "→ Detected VLAN (from IP): $vlan_id"
echo ""

echo "🔍 VLAN DNS Test - alt.lan"
echo "------------------------------"

PIHOLE_IP="192.168.10.2"
echo "Using Pi-hole IP: $PIHOLE_IP"
echo

# 1. Test system DNS assignment
echo "1️⃣  Testing DNS server assignment..."
system_dns=$(scutil --dns | awk '/nameserver\[[0-9]+\]/ {print $3}' |
head -n1)
echo "→ System DNS: $system_dns"
if [[ "$system_dns" == "$PIHOLE_IP" ]]; then
  echo "✅ Correct DNS IP"
else
  echo "❌ Unexpected DNS IP"
fi
echo 

# 2. Test example.com resolution
echo "2️⃣  dig example.com"
dig +short example.com
echo

# 3. DNSSEC Valid Test (sigok)
echo "3️⃣  DNSSEC Valid Test (sigok)"
dig +dnssec sigok.verteiltesysteme.net
echo

# 4. DNSSEC Invalid Test (sigfail)
echo "4️⃣  DNSSEC Invalid Test (sigfail)"
dig +dnssec sigfail.verteiltesysteme.net
echo "✅ Should see no output (SERVFAIL)"
echo

# 5. Recursive query test (random domain)
echo "5️⃣  Recursive query test (random domain)"
dig +nocmd random12345.openai.com +noall +stats
echo
  
# 6. Blocklist test (googleads)
echo "6️⃣  Blocklist test (googleads)"
dig +short googleads.g.doubleclick.net
echo "✅ Should return 0.0.0.0 or nothing"