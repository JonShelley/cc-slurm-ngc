#!/bin/bash

# Download the following packages and place them in ndv4/cluster-init/files

BASE_DIR=specs/ndv4/cluster-init/files
mkdir -p $BASE_DIR
cd $BASE_DIR

# Download enroot packages
wget https://github.com/NVIDIA/enroot/releases/download/v3.3.0/enroot_3.3.0-1_amd64.deb 
wget https://github.com/NVIDIA/enroot/releases/download/v3.3.0/enroot+caps_3.3.0-1_amd64.deb

# Download nephele package
wget https://github.com/NVIDIA/nephele/archive/refs/heads/ubuntu-18.04.zip -O nephele-ub18.04.zip

# Download nvtop
wget https://github.com/Syllo/nvtop/archive/refs/tags/1.2.2.tar.gz -O nvtop-1.2.2.tar.gz

# Download PMIX
wget https://github.com/openpmix/openpmix/archive/refs/tags/v3.1.6.tar.gz -O openpmix-v3.1.6.tar.gz

# Download Pyxis
wget https://github.com/NVIDIA/pyxis/archive/refs/tags/v0.11.1.tar.gz -O pyxis-v0.11.1.tar.gz

