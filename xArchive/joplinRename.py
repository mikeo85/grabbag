# script for renaming Joplin raw export files based on the first line of the file
# NOTE: I did not create this. I copied most of it from somewhere else then modified... but it was a while ago and I have no idea where. Apologies to the original author.
import os

# ACTION REQUIRED: INPUT LOCATION BEFORE RUNNING SCRIPT
location = '<tbd>'
files_in_dir = []

# r=> root, d=>directories, f=>files
for r, d, f in os.walk(location):
    for item in f:
        files_in_dir.append(os.path.join(r, item))

for item in files_in_dir:
#    print item
    with open(item) as f:
        first_line=f.readline().strip()
        first_line=first_line[:100]
        first_line=location + '/CONVERTED/' + first_line + '.md'
#    print(' => ',first_line)
    try:
        os.rename(item,first_line)
    except:
        print 'error' + item

print 'done'
