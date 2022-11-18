#!/bin/bash

# digg.sh
#  Usage: digg [domain|ip|url]
#  Examples:
#       digg https://google.com/
#       digg 67.1.1.1
#       digg www.example.com


# Fuction: Test an IP address for validity:
# Usage:
#      valid_ip IP_ADDRESS
#      if [[ $? -eq 0 ]]; then echo good; else echo bad; fi
#   OR
#      if valid_ip IP_ADDRESS; then echo good; else echo bad; fi
#
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

function arin()
{
  curl "http://whois.arin.net/rest/ip/${1}.txt"
}

# If this is an IP, just get the ARIN Whois info
if valid_ip "$1"; then
  arin "$1"
else
  # extract the protocol
  proto=$(echo "$1" | grep :// | sed -e's,^\(.*://\).*,\1,g')
  # remove the protocol
  url=$(echo "${1/$proto/}")
  # extract the user (if any)
  user=$(echo "$url" | grep @ | cut -d@ -f1)
  # extract the host
  host="$(echo "${url/$user@/}" | cut -d/ -f1)"
  base_domain=$(sed -E 's/.*\.([a-z]+\.[a-z]+$)/\1/' <<< "$host")
  # by request - try to extract the port
  #port="$(echo $host | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"
  # extract the path (if any)
  #path="$(echo $url | grep / | cut -d/ -f2-)"

  echo "--------------------------------------"
  echo "----------------- Whois --------------"
  echo "--------------------------------------"
  whois "$base_domain" | grep 'Registr\|Name\|Date' # Only look for important info

  echo "--------------------------------------"
  echo "------------ Name Servers ------------"
  echo "--------------------------------------"
  dig "$base_domain" -t NS +noall +answer

  echo ""
  echo "--------------------------------------"
  echo "----------------- MX -----------------"
  echo "--------------------------------------"
  dig "$base_domain" -t MX +noall +answer

  echo ""
  echo "--------------------------------------"
  echo "---------- A(AAA), CNAME -------------"
  echo "--------------------------------------"
  dig "$host" +noall +answer
  dig "$base_domain" +noall +answer

  echo ""
  echo "--------------------------------------"
  echo "----------- ARIN WHOIS ---------------"
  echo "--------------------------------------"
  for ip in $(dig "$host" +short); do
    if valid_ip "$ip"; then
      arin "$ip"
    fi
  done
fi