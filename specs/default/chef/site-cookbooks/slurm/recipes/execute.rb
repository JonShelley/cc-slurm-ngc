#
# Cookbook Name:: slurm
# Recipe:: execute
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

include_recipe "slurm::default"
require 'chef/mixin/shell_out'

slurmuser = node[:slurm][:user][:name]

remote_file '/etc/munge/munge.key' do
  source 'file:///sched/munge/munge.key'
  owner 'munge'
  group 'munge'
  mode '0700'
  action :create
end

link '/etc/slurm/slurm.conf' do
  to '/sched/slurm.conf'
  owner "#{slurmuser}"
  group "#{slurmuser}"
end

link '/etc/slurm/cyclecloud.conf' do
  to '/sched/cyclecloud.conf'
  owner "#{slurmuser}"
  group "#{slurmuser}"
end

link '/etc/slurm/cgroup.conf' do
  to '/sched/cgroup.conf'
  owner "#{slurmuser}"
  group "#{slurmuser}"
end

link '/etc/slurm/topology.conf' do
  to '/sched/topology.conf'
  owner "#{slurmuser}"
  group "#{slurmuser}"
end

link '/etc/slurm/gres.conf' do
  to '/sched/gres.conf'
  owner "#{slurmuser}"
  group "#{slurmuser}"
  only_if { ::File.exist?('/sched/gres.conf') }
end

link '/etc/hosts' do
  to '/sched/slurm_hosts'
  owner 'root'
  group 'root'
  only_if { ::File.exist?('/sched/slurm_hosts') }
end

defer_block "Defer starting slurmd until end of converge" do
  nodename = node[:cyclecloud][:node][:name]
  #slurmd_sysconfig="SLURMD_OPTIONS=-N #{nodename}"
  slurmd_sysconfig="SLURMD_OPTIONS=-N #{nodename} \nPMIX_MCA_ptl=^usock \nPMIX_MCA_psec=none \nPMIX_SYSTEM_TMPDIR=/var/empty \nPMIX_MCA_gds=hash \nHWLOC_COMPONENTS=-opencl"

  myplatform=node[:platform]
  case myplatform
  when 'ubuntu'
    directory '/etc/sysconfig' do
      action :create
    end
    
    file '/etc/sysconfig/slurmd' do
      content slurmd_sysconfig
      mode '0700'
      owner 'slurm'
      group 'slurm'
    end
  when 'centos', 'rhel', 'redhat'
    file '/etc/sysconfig/slurmd' do
      content slurmd_sysconfig
      mode '0700'
      owner 'slurm'
      group 'slurm'
    end
  end

  service 'slurmd' do
    action [:enable, :start]
  end

  service 'munge' do
    action [:enable, :restart]
  end

  # Re-enable a host the first time it converges in the event it was drained
  # set the ip as nodeaddr and hostname in slurm
  execute 'Update node to ipaddr' do
    command "scontrol update nodename=#{nodename} NodeAddr=#{node[:ipaddress]} NodeHostname=#{node[:ipaddress]}"
  end
  
  # update the slurm hosts file
  execute 'update slurm_hosts file' do
    command "/opt/cycle/jetpack/system/embedded/bin/python /mnt/cluster-init/slurm/default/scripts/010-update-hosts-file.py"
  end
  
  # Take a quick break to insure that the services are available before slurm schedules a job
  execute 'take 5' do
    command "/bin/sleep 5"
  end
  
  # Set the slurm node to active
  execute 'set node to active' do
    command "scontrol update nodename=#{nodename} state=UNDRAIN && touch /etc/slurm.reenabled"
    creates '/etc/slurm.reenabled'
  end
end
