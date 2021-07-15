!#/bin/bash
# bash script to prep and auto-mount NFS shares
# must run as root
# first need to fill in the variables below
#
# VARIABLES
NFSUSERNAME='user'
NFSPASSWORD='pwd'
MOUNTPOINT1='nfs://<IP>/nfs/<NFS_Name>'
MOUNTPOINT2=''
NFSPATH1=''
NFSPATH2=''
#
#
# SCRIPT START
apt-get install cifs-utils nfs-common
echo 'username=$(NFSUSERNAME)
password=$(NFSPASSWORD)' >> ~/.smbcredentialstest
