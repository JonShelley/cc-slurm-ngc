# Setup CycleCloud to run NGC containers using Slurm, Pyxis, and Enroot

## Requirements
* CycleCloud 8.1+

## Deploy the cyclecloud server and ssh into the VM
_Note: Please follow [Cycle Cloud Quickstart guide](https://docs.microsoft.com/en-us/azure/cyclecloud/qs-install-marketplace?view=cyclecloud-8) with the below recommendations_

__Recommendations:__
- Create a new resource group (i.e cc-manager) and then select your newly created resource group and create your cyclecloud server.
- Select Azure CycleCloud 8.1(or higher) and click create
    - Fill out the requested information and deploy your CycleCloud server.
- Server size: D4s_v4 (Recommended)
- Create a uniquely named storage account (i.e. cc-storage-name) in your newly created resource group.

Once deployed:
 - Go to the newly created Cycle Cloud server and record the ip address. 
 - Login to the Cycle Cloud server in your Web Browser and do the initial setup of your Cycle Cloud server
 - ssh into your cyclecloud server (i.e. ssh azureuser@<cc-srv-ip>) and follow the steps below

### Download and setup the project
Initialize Cycle Cloud
```shell
cyclecloud initialize
```

Before running the below code block change \<azure-storage\> to the correct locker name. To see the available lockers run
- cyclecloud locker list 

```shell
sudo yum install -y git
cd ~/
git clone -b 2.4.8 https://github.com/Azure/cyclecloud-slurm.git cc-slurm-ngc
cyclecloud project fetch https://github.com/Azure/cyclecloud-slurm/releases/2.4.8 cc-slurm-ngc
cd cc-slurm-ngc
git submodule add https://github.com/JonShelley/cc-slurm-ngc.git
cd cc-slurm-ngc
./download_dependancies.sh
cp -R specs/* ../specs
cp -R templates/* ../templates
cd ..
cyclecloud project upload \<azure-storage\>  # Change this to your locker name
cd templates
cyclecloud import_template cc-slurm-ngc -f ./cc-slurm-ngc.txt -c slurm
```

_Note:_ At this point you are ready to deploy your cyclecloud cluster

## Deploy your cyclecloud cluster
Open a web browser and go to your cyclecloud server (https://cc-srv-ip)

Once you have logged in to your cyclecloud server:
_Note:_ If this is your first time logging in you will need to fill out some information before you can proceed

Use the following link to learn more about creating a cluster (https://docs.microsoft.com/en-us/azure/cyclecloud/how-to/create-cluster?view=cyclecloud-8)

_Note: Only tested with Ubuntu-HPC 18.04 marketplace image_
 
 Tips: 
 - In the _Schedulers_ section, select slurm-ngc
 - In the "Required Settings" tab
   - Uncheck "autoscale" if you don't want VMs to automatically shut off when nodes sit idle 
   - Change HPC VM Type to use ND 
     - In the SKU Search bar type ND then select either ND96asr\_v4, or ND96amsr_A100_v4.
  - Update value from Max HPC Cores to the desired # of VMs * # of cores/VM
 - In the "Advanced Settings" tab
   - Set the scheduler OS to use a custom image
     - microsoft-dsvm:ubuntu-hpc:1804:latest
   - Set the HPC OS to use a custom image
     - microsoft-dsvm:ubuntu-hpc:1804:latest
   - If you plan to use the HTC partitions, I would recommned that you use the same OS image as the others
   
 

 ## Testing out the deployment
 _Note: If you don't want to deal with auto scaling when testing, add "SuspendExecParts=hpc" to /etc/slurm/slurm.conf and restart slurm (sudo systemctl restart slurmctld) once the scheduler has been deployed_
    
 Once the Scheduler and Compute VMs have been provisioned, ssh into the scheduler and follow the instructions below
```shell
sudo chmod 1777 /shared
mkdir -p /shared/data
cd /shared/data
git clone https://github.com/JonShelley/azure
```
 
At this point the system should be ready to run some quick tests to verify that the system is working as expected
 - [HPL](https://github.com/JonShelley/azure/tree/master/benchmarking/NDv4/cc-slurm-ngc/hpl)
 - [NCCL - All Reduce](https://github.com/JonShelley/azure/tree/master/benchmarking/NDv4/cc-slurm-ngc/nccl)
 - [Utility scripts](https://github.com/JonShelley/azure/tree/master/benchmarking/NDv4/cc-slurm-ngc/util_scripts)
