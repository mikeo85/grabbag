#!/usr/bin/env bash
############################################################
#
#  Install Docker on Ubuntu
#  ---------------------------------------------------------
#  Just automating the process
#
#        Written by: Mike Owens
#        Email:      mikeowens (at) fastmail (dot) com
#        Website:    https://michaelowens.me
#        GitLab:     https://gitlab.com/mikeo85
#        GitHub:     https://github.com/mikeo85
#        Twitter:    https://twitter.com/quietmike8192
#
#  Basically just collecting the instructions from Docker
#  Docs in one place. Includes initial install, recommended
#  post-installation steps, and enabling Docker daemon to
#  start on login.
#
#  Refs:
#  - https://docs.docker.com/engine/install/ubuntu/
#  - https://docs.docker.com/engine/install/linux-postinstall/
#  - https://docs.docker.com/compose/install/
#  
############################################################

echo "Running $(basename "$0")..."
# //============ BEGIN SCRIPT BODY =============\\

# Initialize Variables
# ================================================
declare -i stepNum
stepNum=0

# Define Functions
# ================================================
stepHeader() {
    ((stepNum++))
    echo "+---------------------------------------"
    echo "| Step $stepNum: $stepName"
    echo "+---------------------------------------"
}

stepFooter() {
    echo "~~~ $stepName complete ~~~"
}

promptUserConfirmation() {
	while true; do
    read -p "Continue (y/n)? " choice
    case "$choice" in 
      y|Y ) echo "Continuing..." && break;;
      n|N ) echo "Terminating..." && exit;;
      * ) echo "Invalid entry. Try again...";;
    esac
	done
}

catchError() {
    echo "ERROR: An error occurred with step \'$stepName\'"
    promptUserConfirmation
}

# Begin Execution
# ================================================

stepName="Uninstall Old Docker Versions"
stepHeader
sudo apt-get remove docker docker.io containerd runc || catchError
stepFooter

stepName="Set up the repository"
stepHeader
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release || catchError
stepFooter

stepName="Add Docker official GPG key"
stepHeader
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
stepFooter

stepName="Set up the stable repository"
stepHeader
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
stepFooter

stepName="Install Docker Engine"
stepHeader
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y || catchError
stepFooter

# # Verify that Docker Engine is installed correctly by running the hello-world image.
# sudo docker run hello-world

# read -p "If the 'Hello World' container worked successfully, press any key to continue. Otherwise press Ctrl-C to break and exit the script for troubleshooting." choice

# # Create the docker group. # Seems like this is already done
#sudo groupadd docker

stepName="Add your user to the docker group"
stepHeader
sudo usermod -aG docker $USER || catchError
# newgrp docker || catchError
stepFooter

# #Verify that you can run docker commands without sudo.
# docker run hello-world

# read -p "If the 'Hello World' container worked successfully, press any key to continue. Otherwise press Ctrl-C to break and exit the script for troubleshooting." choice

stepName="Configure Docker to start on boot"
stepHeader
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
stepFooter

stepName="Download the current stable release of Docker Compose"
stepHeader
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose || catchError
sudo chmod +x /usr/local/bin/docker-compose
stepFooter

stepName="Enable bash completion"
stepHeader
sudo curl \
    -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose \
    -o /etc/bash_completion.d/docker-compose || catchError
stepFooter

# done
echo "+++++ Docker Installation and Configuration Complete +++++"
echo ""
echo "!!! RECOMMENDATION: Run the following command"
echo "    to enable user group changes in the current shell:"
echo ""
echo "    $ newgrp docker"
echo ""
# \\============= END SCRIPT BODY ==============//
echo "$(basename "$0") complete."
