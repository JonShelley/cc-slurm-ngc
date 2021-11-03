#!/usr/bin/env python

import subprocess
import re
import os
import shutil

cmd="scontrol show node"

output = subprocess.check_output(cmd, shell=True)

print("Type: {}".format(type(output)))
nodes = output.decode("utf-8").split("\n\n")
print("Nodes: {}".format(len(nodes)))


# Check to see if /etc/hosts.orig exists
if not os.path.isfile("/sched/slurm_hosts.orig"):
    shutil.copyfile("/etc/hosts","/sched/slurm_hosts.orig")


# Append to /etc/hosts
outfilename = "/sched/slurm_hosts"
outfile = open(outfilename, "a")
outfile.write("\n--------------------Slurm Aliases----------------------")

for node in nodes:
    results = dict(re.findall(r'(\w*)=(\".*?\"|\S*)', node))
    if "NodeName" in results and "NodeAddr" in results and results["NodeName"] != results["NodeAddr"]:
        outfile.write("\n{} {}".format(results["NodeAddr"],results["NodeName"]))
outfile.close()
