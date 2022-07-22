#!/bin/bash

# USE AT YOUR OWN RISK
# NO CLAIM OF FITNESS FOR ANY PURPOSE

# vast.ai radiant blockchain bfgminer mining script
# Instance Configuration
# Image: nvidia/opencl:latest 

apt update
DEBIAN_FRONTEND=noninteractive apt -y upgrade
apt -y install uthash-dev screen libjansson4 libjansson-dev ocl-icd-* opencl-headers libcurl4-openssl-dev \
        pkg-config libtool autoconf git build-essential autogen automake libncurses5-dev libevent-dev bc

git clone https://github.com/radiantblockchain/rad-bfgminer.git "$HOME"/rad-bfgminer
cd "$HOME"/rad-bfgminer
git config --global url.https://github.com/.insteadOf git://github.com/
./autogen.sh
./configure --enable-opencl
make -j $(echo "$(nproc) - 1" | bc)

"$HOME"/rad-bfgminer/bfgminer -S opencl:auto -o http://master.radiantblockchain.org:7332 -u raduser -p radpass \
	--set-device OCL:kernel=poclbm --coinbase-sig hello-miner --generate-to 1NTAraUNiLw1tynMSMv9WFvKrpEVoMhaSe
