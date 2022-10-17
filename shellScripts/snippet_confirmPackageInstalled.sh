# Function to confirm a package is installed on the system (using dpkg)
# Exit code is 0 for success, 1 for failure

confirmPackageInstalled() {
	if [[ $(dpkg -l | grep -c $1) -gt 0 ]]; then
		exit 0
	else
		exit 1
	fi
}