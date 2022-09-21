############################################################
# Get the LAN / Network IP address of the host
# and the network interface
# ==========================================================
# Source: https://stackoverflow.com/a/21336679
############################################################

my_ip=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')

my_interface=$(ip route get 8.8.8.8 | awk -F"dev " 'NR==1{split($2,a," ");print a[1]}')
