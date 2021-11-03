#!/usr/bin/env python

import subprocess
import re
import os
import shutil

shosts_orig="/sched/slurm_hosts.orig"
shosts_file="/sched/slurm_hosts"


# Check to see if /etc/hosts.orig exists
if not os.path.isfile(shosts_orig):
    shutil.copyfile("/etc/hosts",shosts_orig)

# Copy over fresh slurm_hosts file
#shutil.copyfile(shosts_orig, shosts_file)

# Get the node information
cmd="scontrol show node"

output = subprocess.check_output(cmd, shell=True)

print("Type: {}".format(type(output)))
nodes = output.decode("utf-8").split("\n\n")
print("Nodes: {}".format(len(nodes)))

orig_file = open(shosts_orig) 
orig_lines = orig_file.read() 
orig_file.close()

# Write new shosts_file
outfile = open(shosts_file, "w")
outfile.write("{}".format(orig_lines))

outfile.write("\n--------------------Slurm Aliases----------------------")

for node in nodes:
    results = dict(re.findall(r'(\w*)=(\".*?\"|\S*)', node))
    if "NodeName" in results and "NodeAddr" in results and results["NodeName"] != results["NodeAddr"]:
        outfile.write("\n{} {}".format(results["NodeAddr"],results["NodeName"]))
outfile.close()
