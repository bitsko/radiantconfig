#!/bin/bash
# compile and run rad-bfgminer on ubuntu/debian
# https://github.com/RadiantBlockchain/rad-bfgminer

sudo apt -y install uthash-dev screen libjansson4 libjansson-dev ocl-icd-* opencl-headers libcurl4-openssl-dev \
        pkg-config libtool autoconf git build-essential autogen automake libncurses5-dev libevent-dev

git clone https://github.com/radiantblockchain/rad-bfgminer.git "$HOME"/rad-bfgminer
cd "$HOME"/rad-bfgminer
git config --global url.https://github.com/.insteadOf git://github.com/
./autogen.sh
./configure --enable-opencl
make

# run the miner with this string:
"$HOME"/rad-bfgminer/bfgminer -S opencl:auto -o http://master.radiantblockchain.org:7332 -u raduser -p radpass \
	--set-device OCL:kernel=poclbm --coinbase-sig hello-miner --generate-to 1NTAraUNiLw1tynMSMv9WFvKrpEVoMhaSe   
