#!/bin/bash
sudo true || { echo "sudo failed, bailing"; exit 1; }
echo -n "Detecting ipv4 gateway... "
gw4=$(ip route get 8.8.8.8 | awk '{print $3}')
echo "$gw4"
destinations="login.launchpad.net launchpad.net git.launchpad.net cloud-images.ubuntu.com"
destinations="$destinations reqorts.qa.ubuntu.com"
destinations="$destinations landscape.canonical.com ppa.launchpad.net"
destinations="$destinations cdimage.ubuntu.com canonical.images.linuxcontainers.org"
destinations="$destinations login.ubuntu.com bugs.launchpad.net images.maas.io"
destinations="$destinations private-ppa.launchpad.net"
destinations="$destinations autopkgtest.ubuntu.com"
echo "Dropping all ipv6 routes via the tunN interface"
targets=$(ip -6 route | grep -E "tun[0-9]" | grep -E "^[0-9]" | awk '{print $1}')
for target in $targets; do
    echo $target
    sudo ip route del $target
done
echo "done"
for d in $destinations; do
    ipv4s=$(dig +short $d -t A)
    #ipv6s=$(dig +short $d -t AAAA)
    ips="$ipv4s $ipv6s"
    echo "Checking destination $d ($(echo $ips))"
    for ip in $ips; do
        route_get="$(ip route get $ip|head -n 1)"
        if echo "$route_get" | grep -q "dev tun0"; then
            echo "Forcing destination $d (ip $ip) to skip the vpn"
            if echo $ip | grep -q :; then
                sudo route -6 add "$ip" via "$gw6"
            else
                sudo ip route add "$ip" via "$gw4"
            fi
        fi
    done
done
