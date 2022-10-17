# Function to confirm a package is installed on the system (using dpkg)
# Exit code is 0 for success, 1 for failure

confirmPackageInstalled() { if [[ $(dpkg -l | grep -c $1) -gt 0 ]]; then return 0; else return 1; fi }

# Example Usage:
# confirmPackageInstalled myPackage
# status=$?
# if [[ $status -eq 0 ]]; then
# 	do something
# else
# 	do something else
# fi