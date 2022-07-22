#!/bin/bash

# https://github.com/RadiantBlockchain/radiant-node/
# download and compile radiant blockchain node 
# wget -N https://raw.githubusercontent.com/bitsko/radiantconfig/main/radiant_node_compile.sh && chmod +x radiant_node_compile.sh && ./radiant_node_compile.sh

if ! dpkg -s curl &> /dev/null
	then sudo apt install curl
fi
if ! dpkg -s jq &> /dev/null
	then sudo apt install jq
fi

radiant_ver=$(curl -s https://api.github.com/repos/RadiantBlockchain/radiant-node/releases/latest |jq .tag_name | sed 's/"//g;s/v//g')
# radiant_ver="1.0.5"

radiant_url="https://github.com/RadiantBlockchain/radiant-node/archive/refs/tags/"
radiant_zip="v$radiant_ver.tar.gz"
radiant_dir="$HOME/.radiant"

if [[ -d "$radiant_dir" ]]; then
	echo $'\n'"backing up existing radiant directory"$'\n'
	IFS= read -r -p "stop your node first. press enter to continue" radiant_any
	cp -r $HOME/.radiant $HOME/radiant.$EPOCHSECONDS.backup
#	echo "existing .radiant folder backed up to: $HOME/radiant.$EPOCHSECONDS.backup"
fi

if [[ ! -d "$radiant_dir" ]]; then
	mkdir "$radiant_dir"
fi

sudo apt update
sudo apt -y install build-essential git cmake \
  pkg-config libtool autoconf autogen automake libboost-chrono-dev wget \
	libboost-filesystem-dev libboost-test-dev libboost-thread-dev libevent-dev \
	libminiupnpc-dev libssl-dev libzmq3-dev help2man ninja-build python3 libdb-dev \
	libdb++-dev libqrencode-dev libcurl4-openssl-dev libncurses-dev

wget "$radiant_url$radiant_zip"
tar -zxvf "$radiant_zip"

mkdir radiant-node-"$radiant_ver"/build
cd radiant-node-"$radiant_ver"/build
cmake -GNinja .. -DBUILD_RADIANT_QT=OFF
ninja

cp src/radiant-cli "$radiant_dir"/radiant-cli && strip "$radiant_dir"/radiant-cli
cp src/radiant-tx "$radiant_dir"/radiant-tx && strip "$radiant_dir"/radiant-tx
cp src/radiant-wallet "$radiant_dir"/radiant-wallet && strip "$radiant_dir"/radiant-wallet
cp src/radiantd "$radiant_dir"/radiantd && strip "$radiant_dir"/radiantd

if [[ ! -f "$radiant_dir/radiant.conf" ]]; then
  IFS= read -r -p "enter a username for radiantd"$'\n>' radiant_usr
  IFS= read -r -p "enter a rpc password for radiantd"$'\n>' radiant_pwd
  echo "port=7332"$'\n'\
       	"rpcport=7333"$'\n'\
       	"rpcuser=$radiant_usr"$'\n'\
	"rpcpassword=$radiant_pwd"$'\n'\
	"txindex=1"$'\n'> "$radiant_dir/radiant.conf"
fi

unset radiant_url
unset radiant_zip
unset radiant_dir
unset radiant_any
unset radiant_usr
unset radiant_pwd
unset radiant_ver
