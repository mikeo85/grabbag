#!/bin/bash
############################################################
#
#  PREQUEL: LINUX SETUP AND HARDENING
#  ---------------------------------------------------------
#  Bash script that automates initial setup and hardening
#  of a new linux install (Debian-family).
#
#        Written by: Mike Owens
#        Email:      mikeowens (at) fastmail (dot) com
#        Website:    https://michaelowens.me
#        GitLab:     https://gitlab.com/mikeo85
#        GitHub:     https://github.com/mikeo85
#        Twitter:    https://twitter.com/quietmike8192
#
############################################################

echo "Running $(basename "$0")..."
# //============ BEGIN SCRIPT BODY =============\\

##############################################################
# Initialize variables
##############################################################
stepNum="0"

##############################################################
# Basic checks before starting
##############################################################

# No root - no good
[ "$(id -u)" != "0" ] && {
    usage "ERROR: You must be root to run this script.\\nPlease login as root and execute the script again."
    exit 1
}

# Fail-fast: No apt - no good
if ! command -v apt-get >/dev/null; then
    printf "Error: Apt package manager not found. Terminating."
    exit 1
fi

##############################################################
# Internal Functions
##############################################################
showBanner(){
    echo "

     ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄
    ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌
    ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░▌
    ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          ▐░▌
    ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░▌
    ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌
    ▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀█░█▀▀ ▐░█▀▀▀▀▀▀▀▀▀ ▐░█▄▄▄▄▄▄▄█░▌▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░▌
    ▐░▌          ▐░▌     ▐░▌  ▐░▌          ▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░▌          ▐░▌
    ▐░▌          ▐░▌      ▐░▌ ▐░█▄▄▄▄▄▄▄▄▄  ▀▀▀▀▀▀█░█▀▀ ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄
    ▐░▌          ▐░▌       ▐░▌▐░░░░░░░░░░░▌        ▐░▌  ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
    ▀            ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀          ▀    ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀

    A Linux Setup and Hardening Script
    By Mike Owens [ GitHub / GitLab: @mikeo85 ]"
    echo
}

promptContinue() {
    local __resultVar=$1
    while true; do
        read -p "Continue Y/N (<Enter> for Y): " choice
        case "$choice" in
            y|Y|'' ) local funcResult="Y" && break;;
            n|N ) local funcResult="N" && break;;
            * ) echo "Invalid entry. Try again...";;
        esac
    done
    if [ "$__resultVar" ]; then
        eval $__resultVar="'$funcResult'"
    else
        echo "$funcResult"
    fi
}

stepHeader() {
    (( ++stepNum ))
    stepName="$1"
    _padding=$(expr 60 - $(expr $(expr length "$stepNum$stepName") + 7))
    printf "\n# ===== STEP %s: %s %s\n" "$stepNum" "$stepName" "$(printf %"$_padding"s |tr " " "=")"
}

runStep() {
    stepHeader "$2"
    $1 i
    promptContinue doStep
    if [ "$doStep" == "Y" ]; then
        $1 x
    else
        printf "Skipping Step %s: %s...\n" "$stepNum" "$stepName"
    fi
}

##############################################################
# MAIN SETUP AND HARDENING
##############################################################
clear
showBanner

# ===== FUNCTION TEMPLATE =================================
myFunction () {
    if [ "$1" = "i" ]; then
        # Function Info
        echo "About the template function..."
    elif [ "$1" = "x" ]; then
        # Execute Function
        echo "Replace this line with the function"
    else
        echo "Error: Invalid function input. No action performed."
    fi
}

# ===== THE FUNCTIONS ===========================
aptUpdate () {
    if [ "$1" = "i" ]; then
        # Function Info
        echo "Run apt update, upgrade, dist-upgrade, & autoremove"
    elif [ "$1" = "x" ]; then
        # Execute Function
        apt update
        apt upgrade -y
        apt dist-upgrade
        apt autoremove
    else
        echo "Error: Invalid function input. No action performed."
    fi
}

updateHostname () {
    if [ "$1" = "i" ]; then
        # Function Info
        HOSTNAME=$(hostname)
        printf "Current hostname is '%s'. Do you want to change it?\n" "$HOSTNAME"
    elif [ "$1" = "x" ]; then
        # Execute Function
        read -p "New Hostname: " newHostname
        newHostname=${newHostname//[^[:alnum:]]/}
        printf "New hostname will be '%s'. Please confirm.\n" "$newHostname"
        promptContinue carryOn
        if [ "$carryOn" == "Y" ]; then
            hostnamectl set-hostname "$newHostname"
            if [ "$?" -eq 0 ];then
                printf "Hostname has been changed to %s.\n" "$newHostname"
            else
                printf "An error occurred.\n"
                promptUserConfirmation
            fi
        else
            printf "Hostname has NOT been changed.\n"
        fi
    else
        echo "Error: Invalid function input. No action performed."
    fi
}

installAptBasics() {
    if [ "$1" = "i" ]; then
        # Function Info
        echo "Install basic apt security & update packages, including unattended-upgrades."
    elif [ "$1" = "x" ]; then
        # Execute Function
        apt install apt-listbugs needrestart debsums unattended-upgrades -y
        dpkg-reconfigure -plow unattended-upgrades
    else
        echo "Error: Invalid function input. No action performed."
    fi
}

createAdminUser () {
    if [ "$1" = "i" ]; then
        # Function Info
        echo "Create an admin user other than root."
    elif [ "$1" = "x" ]; then
        # Execute Function
        read -p "Username for new admin user: " newUsername
        newUsername=${newUsername//[^[:alnum:]]/}
        printf "New username will be '%s'. Please confirm.\n" "$newUsername"
        promptContinue carryOn
        if [ "$carryOn" == "Y" ]; then
            # Create the user
            adduser "$newUsername" 
            # Give root privileges
            usermod -aG sudo "$newUsername"
        else
            printf "User has NOT been added.\n"
        fi
    else
        echo "Error: Invalid function input. No action performed."
    fi
}

setMOTD () {
    if [ "$1" = "i" ]; then
        # Function Info
        echo "Display ascii art of the hostname at SSH login."
    elif [ "$1" = "x" ]; then
        # Execute Function
        # Install figlet if necessary
        if [ $(dpkg -l | grep -c figlet) -eq 0 ]; then
            apt install figlet
        fi
        (figlet -f future $(hostname) || figlet $(hostname)) > /etc/motd
        echo ""
        echo "New MOTD:"
        echo ""
        cat /etc/motd
        echo ""
        systemctl restart sshd
    else
        echo "Error: Invalid function input. No action performed."
    fi
}

setWarningBanner() {
    # - https://www.tecmint.com/ssh-warning-banner-linux/
    if [ "$1" = "i" ]; then
        # Function Info
        echo "Enable a warning banner for SSH logins"
    elif [ "$1" = "x" ]; then
        # Execute Function
        echo "------------------------------------------------------------
------------------------------------------------------------

Authorized access only!

If you are not authorized to access or use this system, disconnect now!

------------------------------------------------------------
------------------------------------------------------------" > /etc/sshWarningBanner
    sed -i 's/#Banner none/Banner \/etc\/sshWarningBanner/' /etc/ssh/sshd_config
    systemctl restart sshd
    else
        echo "Error: Invalid function input. No action performed."
    fi
}

setupUFW () {
    if [ "$1" = "i" ]; then
        # Function Info
        echo "Install, configure, and enable UFW, the Uncomplicated Firewall."
    elif [ "$1" = "x" ]; then
        # Execute Function
        # Install UFW if necessary
        if [ $(dpkg -l | grep -c ufw) -eq 0 ]; then
            apt install ufw
        fi
        # Proceed only when UFW is installed
        if [[ $(dpkg -l | grep -c ufw) -gt 0 ]]; then
            echo "Setting ufw for ssh, http, https"
            ufw allow ssh && ufw allow http && ufw allow https 
            echo "Enabling ufw"
            echo "y" | ufw enable
        else
            echo "Skipping UFW config as it does not seem to be installed."
        fi
    else
        echo "Error: Invalid function input. No action performed."
    fi
}

configureFail2Ban () {
    if [ "$1" = "i" ]; then
        # Function Info
        echo "Configure Fail2Ban, an intrusion prevention software that protects against brute-force attacks by automatically creating firewall rules to block offending IPs from accessing various network services for a configured time.
    - https://www.fail2ban.org/wiki/index.php/Main_Page
    - https://www.howtogeek.com/675010/how-to-secure-your-linux-computer-with-fail2ban/"
    elif [ "$1" = "x" ]; then
        # Execute Function
        # Install Fail2Ban if necessary
        if [[ $(dpkg -l | grep -c fail2ban) -eq 0 ]]; then
            apt install fail2ban
        fi
        # Proceed only when Fail2ban is installed
        if [[ $(dpkg -l | grep -c fail2ban) -gt 0 ]]; then
            if [[ -f /etc/fail2ban/jail.local ]]; then
                echo "Backing up /etc/fail2ban/jail.local to /etc/fail2ban/jail.local.bak"
                cp /etc/fail2ban/jail.local /etc/fail2ban/jail.local.bak
            else
                echo "Copying /etc/fail2ban/jail.conf to /etc/fail2ban/jail.local"
                cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
                echo "Backing up /etc/fail2ban/jail.conf to /etc/fail2ban/jail.conf.bak"
                cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.bak
            fi

            # Do not do anything if copying jail.conf to jail.local failed
            if [[ -f /etc/fail2ban/jail.local ]]; then
                echo "Determining your physical IP from https://ipinfo.io/ip"
                pub_ip=$(curl https://ipinfo.io/ip 2>> /dev/null) 

                # Start search from the line that contains "[DEFAULT]" - end search before the line that contains "# JAILS"
                echo "/etc/fail2ban/jail.local - Setting bantime = 18000"
                sed -ri "/^\[DEFAULT\]$/,/^# JAILS$/ s/^bantime[[:blank:]]*= .*/bantime = 18000/" /etc/fail2ban/jail.local

                echo "/etc/fail2ban/jail.local - Setting backend = polling"
                sed -ri "/^\[DEFAULT\]$/,/^# JAILS$/ s/^backend[[:blank:]]*=.*/backend = polling/" /etc/fail2ban/jail.local

                echo "/etc/fail2ban/jail.local - Setting ignoreip = 127.0.0.1/8 ::1 ${pub_ip}"
                sed -ri "/^\[DEFAULT\]$/,/^# JAILS$/ s/^ignoreip[[:blank:]]*=.*/ignoreip = 127.0.0.1\/8 ::1 ${pub_ip}/" /etc/fail2ban/jail.local
            fi
            if [[ -f /etc/fail2ban/jail.d/defaults-debian.conf ]]; then
                echo "Backing up /etc/fail2ban/jail.d/defaults-debian.conf to /etc/fail2ban/jail.d/defaults-debian.conf.bak"
                cp /etc/fail2ban/jail.d/defaults-debian.conf /etc/fail2ban/jail.d/defaults-debian.conf.bak
            fi
            echo "Enabling jails in /etc/fail2ban/jail.d/defaults-debian.conf"
            cat <<FAIL2BAN > /etc/fail2ban/jail.d/defaults-debian.conf
[sshd]
enabled = true
maxretry = 3
bantime = 2592000

[sshd-ddos]
enabled = true
maxretry = 5
bantime = 2592000

[recidive]
enabled = true
bantime  = 31536000             ; 1 year
findtime = 86400                ; 1 days
maxretry = 10
FAIL2BAN
            else
                echo "Skipping Fail2Ban config as it does not seem to be installed."
        fi
    else
        echo "Error: Invalid function input. No action performed."
    fi
}

enableSSHOnly () {
    if [ "$1" = "i" ]; then
        # Function Info
        echo "Only allow SSH login with PKI. Disable password login & root login."
    elif [ "$1" = "x" ]; then
        # Execute Function
        ## Get username
        if [[ -n "${newUsername}" ]]; then
            sshUser="$newUsername"
        else
            sshUser="<username>"
        fi
        ## FIRST PROMPT USER TO LOAD THEIR SSH KEY AND VALIDATE ACCESS
        my_ip=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
        my_public_ip=$(curl https://ipinfo.io/ip 2>> /dev/null) 

        echo ""
        echo ""
        echo "Before disabling SSH password login, add your public key to this machine to maintain remote access. Do this using the ssh-copy-id command. "
        echo "IP address to use may vary depending on your networking situation."
        echo "The network IP of this machine is $my_ip. The Internet IP of this machine is $my_public_ip."
        echo ""
        echo "Example (network):  ssh-copy-id -i /path/to/keyfile -o PubkeyAuthentication=no "$sshUser"@$my_ip"
        echo "Example (internet): ssh-copy-id -i /path/to/keyfile -o PubkeyAuthentication=no "$sshUser"@$my_public_ip"
        echo ""
        echo "ADD YOUR SSH KEY AT THIS TIME"
        read -p "Was your SSH key added successfully? (Y/N): " key_confirm
        echo ""
        if [[ $key_confirm == [yY] || $key_confirm == [yY][eE][sS] ]]; then
            echo "Backing up /etc/ssh/sshd_config file to /etc/ssh/sshd_config.bak"
            cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
            echo "Disabling SSH password login..."
            sed -i -E 's/#?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
            sed -i -E 's/#?ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
            sed -i -E 's/#?UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
            sed -i -E 's/#?UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
            echo "Restarting sshd"
            systemctl restart sshd
        fi
    else
        echo "Error: Invalid function input. No action performed."
    fi
}

# ===== EXECUTING THE FUNCTIONS ===========================
runStep aptUpdate "Run System Updates"
runStep updateHostname "Update Machine Hostname"
runStep installAptBasics "Install APT Basics"
runStep createAdminUser "Create Admin User"
runStep setMOTD "Set Message Of The Day"
runStep setWarningBanner "Enable Warning Message"
runStep setupUFW "Set Up UFW"
runStep configureFail2Ban "Configure Fail2Ban"
runStep enableSSHOnly "Enable SSH Key-Only Login"

# \\============= END SCRIPT BODY ==============//
echo "

  _____   ______ _______  _____  _     _ _______             ______   _____  __   _ _______
 |_____] |_____/ |______ |   __| |     | |______ |           |     \ |     | | \  | |______
 |       |    \_ |______ |____\| |_____| |______ |_____      |_____/ |_____| |  \_| |______

        _  _ ____ ____ _  _    ____ ____ ____ ___  ____ _  _ ____ _ ___  _    _   _
        |__| |__| |    |_/     |__/ |___ [__  |__] |  | |\ | [__  | |__] |     \_/ 
        |  | |  | |___ | \_    |  \ |___ ___] |    |__| | \| ___] | |__] |___   |



"
# - https://www.patorjk.com/software/taag/#p=display&f=Cyberlarge&t=Prequel%20done
# - https://www.patorjk.com/software/taag/#p=display&f=Cybermedium&t=Hack%20responsibly
