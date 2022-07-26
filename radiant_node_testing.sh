#!/usr/bin/env bash

# compile the latest version of radiant node
# wget -N https://raw.githubusercontent.com/bitsko/radiantconfig/main/radiant_node_compile.sh && chmod +x radiant_node_compile.sh && ./radiant_node_compile.sh

progress_banner(){ echo $'\n\n'"${radiantTxt} ${debug_step} ${radiantTxt}"$'\n\n'; sleep 2; }
minor_progress(){ echo "	***** $debug_step *****" ; sleep 1; }
debug_location(){
	if [[ "$?" != 0 ]]; then
		echo $'\n\n'"$debug_step has failed!"$'\n\n'
		script_exit
		exit 1
	fi; }
script_exit(){ unset \
		radiantUsr radiantRpc radiantCpu radiantGit radiantDir radiantCnf radiantVer radiantTgz \
		radiantBld radiantTxt radiantSrc radiantBar radiant_OS archos_array deb_os_array debug_step \
		armcpu_array x86cpu_array bsdpkg_array redhat_array cpu_type uname_OS radiantTxt \
		pkg_array_ pkg_to_install progress_banner minor_progress cmake_gninja_noqt \
		nowal_upnp_zmq_qt wallet_disabled_array; }

compile_upnpc=0
compile_zeromq=0

radiantTxt="***********************"
radiantBar="$radiantTxt $radiantTxt $radiantTxt"
wallet_disabled=0
radiantDir="$HOME/.radiant"

echo "$radiantBar"; debug_step="radiant node compile script"; progress_banner
debug_step="declare arrays with bash v4+"
declare -a suse___array=( opensuse-tumbleweed )
declare -a bsdpkg_array=( freebsd OpenBSD NetBSD dragonfly )
declare -a redhat_array=( fedora centos rocky amzn rhel almalinux )
declare -a deb_os_array=( debian ubuntu raspbian linuxmint pop )
declare -a archos_array=( manjaro-arm manjaro endeavouros arch garuda )
declare -a armcpu_array=( aarch64 aarch64_be armv8b armv8l armv7l )
declare -a x86cpu_array=( i686 x86_64 i386 ) # amd64
declare -a nowal_upnp_zmq_qt=( rocky centos amzn rhel )
declare -a wallet_disabled_array=( empty )
declare -a cmake_gninja_noqt=( freebsd fedora debian ubuntu raspbian linuxmint pop \
	manjaro-arm manjaro endeavouros arch dragonfly garuda opensuse-tumbleweed almalinux )
debug_location

cpu_type="$(uname -m)"
uname_OS="$(uname -s)"
radiant_OS=$(if [[ -f /etc/os-release ]]; then source /etc/os-release; echo "$ID"; fi; )
debug_step="find the operating system type"
if [[ -z "$radiant_OS" ]]; then radiant_OS="$uname_OS"; fi
if [[ "$radiant_OS" == "Linux" ]]; then echo "Linux distribution type unknown; cannot check for dependencies"; fi
debug_step="compiling for: $radiant_OS $cpu_type"; progress_banner; echo "$radiantBar"

debug_step="dependencies installation"; progress_banner
if [[ "${suse___array[*]}" =~ "$radiant_OS" ]]; then
	if [[ "$radiant_OS" == opensuse-tumbleweed ]]; then
	sudo zypper dup
	declare -a pkg_array_=( boost-devel libevent-devel libminiupnpc-devel binutils fakeroot m4 \
		make automake autoconf zeromq-devel gzip curl sqlite3 qrencode-devel nano grep \
		libboost_system-devel libboost_filesystem-devel libboost_chrono-devel pkgconf jq wget \
		libboost_program_options-devel libboost_test-devel libboost_thread-devel bc vim clang \
		pv libtool libopenssl-devel help2man ninja libopenssl-devel cmake )
	fi
	while read -r line; do
               if ! which "$line" &>/dev/null; then
			pkg_to_install+=( "$line" )
			debug_location
		fi
	done <<<$(printf '%s\n' "${pkg_array_[@]}")
	if [[ -n "${pkg_to_install[*]}" ]]; then
       	        sudo zypper install -y ${pkg_to_install[*]}
       		debug_location
	fi
elif [[ "${deb_os_array[*]}" =~ "$radiant_OS" ]]; then
	sudo apt update
	sudo apt -y upgrade
	declare -a pkg_array_=( build-essential libtool pkg-config  libcurl4-openssl-dev \
		libncurses-dev autoconf autogen automake libevent-dev libminiupnpc-dev cmake \
		bsdmainutils python3 libevent-dev libboost-system-dev libboost-filesystem-dev \
		libboost-chrono-dev libboost-program-options-dev libboost-test-dev automake \
		libboost-thread-dev libsqlite3-dev libqrencode-dev libdb-dev libdb++-dev \
		libssl-dev miniupnpc bc curl jq wget libzmq3-dev xxd pv help2man ninja-build )
	while read -r line; do
        	if ! dpkg -s "$line" &> /dev/null; then
			pkg_to_install+=( "$line" )
		fi
       	done <<<$(printf '%s\n' "${pkg_array_[@]}")
	if [[ -n "${pkg_to_install[*]}" ]]; then
                sudo apt -y install ${pkg_to_install[*]}
                debug_location
        fi
	if [[ "${armcpu_array[*]}" =~ "$cpu_type" ]]; then
		if ! dpkg -s g++ &> /dev/null; then
			sudo apt -y install g++-arm-linux-gnueabihf
			debug_location
		fi
	fi
elif [[ "${archos_array[*]}" =~ "$radiant_OS" ]]; then
	sudo pacman -Syu
	declare -a pkg_array_=( boost boost-libs libevent libnatpmp binutils libtool m4 make \
		automake autoconf zeromq gzip curl sqlite qrencode nano fakeroot gcc grep pkgconf \
		sed miniupnpc jq wget bc vim pv xxd ncurses help2man ninja cmake )
	while read -r line; do
        	if ! pacman -Qi "$line" &> /dev/null; then
			pkg_to_install+=( "$line" )
			debug_location
		fi
	done <<<$(printf '%s\n' "${pkg_array_[@]}")
	if [[ -n "${pkg_to_install[*]}" ]]; then
       	        sudo pacman --noconfirm -Sy ${pkg_to_install[*]}
       		debug_location
       	fi
	if [[ "${armcpu_array[*]}" =~ "$cpu_type" ]]; then
		if ! pacman -Qi arm-none-eabi-binutils &> /dev/null; then
			sudo pacman --noconfirm -Sy arm-none-eabi-binutils
			debug_location
		fi
                if ! pacman -Qi arm-none-eabi-gcc &> /dev/null;	then
			sudo pacman --noconfirm -Sy arm-none-eabi-gcc
			debug_location
		fi
	fi
elif [[ "${redhat_array[*]}" =~ "$radiant_OS" ]]; then
       	if [[ -n $(command -v dnf) ]]; then
		sudo dnf update
        else
		sudo yum update
	fi
	if [[ "$radiant_OS" == fedora ]]; then
		declare -a pkg_array_=( gcc-c++ libtool make autoconf automake openssl-devel \
			libevent-devel boost-devel libdb-devel libdb-cxx-devel miniupnpc-devel \
			qrencode-devel gzip jq wget bc vim sed grep zeromq-devel pv ninja-build \
			help2man cmake ncurses curl python39 )
	elif [[ "$radiant_OS" == centos || "$radiant_OS" == rocky ]] || \
		[[ "$radiant_OS" == amzn || "$radiant_OS" == rhel ]] ; then
	        declare -a pkg_array_=( libtool make autoconf automake openssl-devel ncurses curl \
                        libevent-devel boost-devel gcc-c++ gzip jq wget bc vim sed grep libuuid-devel \
			help2man ninja-build cmake python39 libdb-cxx libdb-cxx-devel pip git patch )
	else
		echo "$uname_OS unsupported"
		exit 1
	fi
	if [[ "$radiant_OS" == almalinux ]]; then
		compile_zeromq=1
		compile_upnpc=1
	fi
	while read -r line; do
                if ! rpm -qi "$line" &> /dev/null; then
                        pkg_to_install+=( "$line" )
                        debug_location
                fi
        done <<<$(printf '%s\n' "${pkg_array_[@]}")
        if [[ -n "${pkg_to_install[*]}" ]]; then
               	if [[ -n $(command -v dnf) ]]; then
			sudo dnf install -y ${pkg_to_install[*]}
                else
			sudo yum install -y ${pkg_to_install[*]}
		fi
		if [[ "$radiant_OS" == centos || "$radiant_OS" == rocky ]]; then
			pip install pv
		fi
		debug_location
        fi
elif [[ "${bsdpkg_array[*]}" =~ "$radiant_OS" ]]; then
	if [[ "$uname_OS" == OpenBSD ]]; then
		declare -a pkg_array_=( libevent libqrencode pkgconf miniupnpc jq \
			curl wget gmake python-3.9.13 sqlite3 nano zeromq openssl boost \
			libtool-2.4.2p2 autoconf-2.71 automake-1.16.3 vim-8.2.4600-no_x11 \
			pv ninja help2man cmake )
			# llvm boost git g++-11.2.0p2 gcc-11.2.0p2 ncurses
	elif [[ "$uname_OS" == NetBSD ]]; then
		if [[ -z $(command -v pkgin) ]]; then
			pkg_add pkgin
		fi
		declare -a pkg_array_=( libtool libevent qrencode pkgconf miniupnpc \
			jq curl wget gmake python39 sqlite3 boost nano zeromq openssl autoconf \
			automake ca-certificates boost-libs readline vim llvm clang pv ninja \
			help2man cmake ncurses db5 )
			# db5 llvm clang gcc9 R-BH-1.75.0.0
	elif [[ "$radiant_OS" == freebsd || "$radiant_OS" == dragonfly ]]; then
		pkg upgrade -y
		declare -a pkg_array_=( boost-all libevent autotools libqrencode curl \
			octave-forge-zeromq libnpupnp nano fakeroot pkgconf miniupnpc gzip \
			jq wget db5 libressl gmake python3 sqlite3 binutils gcc clang vim pv \
			ninja help2man cmake ncurses )
	else
		echo "$radiant_OS bsd distro not supported"
	fi
	while read -r line; do
		if ! command -v "$line" >/dev/null; then
			pkg_to_install+=( "$line" )
		fi
	done <<<$(printf '%s\n' "${pkg_array_[@]}")
	if [[ -n "${pkg_to_install[*]}" ]]; then
		if [[ "$radiant_OS" == freebsd ]]; then
			pkg install -y ${pkg_to_install[*]}
			debug_location
		elif [[ "$uname_OS" == "OpenBSD" ]] || [[ "$uname_OS" == "NetBSD" ]]; then
			if [[ -n $(command -v pkgin) ]]; then
				pkgin install ${pkg_to_install[*]}
			else
				pkg_add ${pkg_to_install[*]}
			fi
			debug_location
		fi
	fi
elif [[ "$radiant_OS" == "Linux" ]]; then
	echo "attempting to compile without checking dependencies"
else
	echo "$radiant_OS unsupported"
	script_exit
	unset -f script_exit
	exit 1
fi

cmake_version=$(cmake -version | head -n 1 | cut -d ' ' -f 3 | sed 's/\.//g' | cut -c -3)
if (( $(echo "$cmake_version < 313" | bc -l) )); then
	debug_step="CMake 3.13 or higher is required. You are running version $(cmake -version | cut -d ' ' -f 3)"; progress_banner
	echo "aborting installation"
	script_exit
	unset -f script exit
	exit 1
fi

# end dependency installation script

debug_step="making directories, backing up .radiant folder if present"; minor_progress
if [[ ! -d "$radiantDir" ]]; then
	mkdir "$radiantDir"
	debug_location
elif [[ -d "$radiantDir" ]]; then
	debug_step="backing up existing radiant directory"; progress_banner
	if [[ -f "$radiantDir/radiant.pid" ]]; then
		IFS= read -r -p "stop your node first if running. press enter to continue"
		radiantPid=$(cat "$radiantDir"/radiantd.pid)
		echo "kill $radiantPid"
		echo "or $radiantBin/radiant-cli stop"
		unset radiantPid
	fi
	cp -r "$radiantDir" "$HOME"/radiant."$EPOCHSECONDS".backup
	debug_location
	echo "existing .radiant folder backed up to: $HOME/radiant.$EPOCHSECONDS.backup"
fi

debug_step="finding the latest release version"; echo "$debug_step"
if [[ -n $(command -v jq) && -n $(command -v curl) ]]; then
	radiantVer="$(curl -s https://api.github.com/repos/RadiantBlockchain/radiant-node/releases/latest |jq .tag_name | sed 's/"//g;s/v//g')"
	debug_location
else
	debug_step="*** jq or curl not installed, dependencies installation failed"
	script_exit
	unset script_exit
	exit 1
fi

radiantBin="$radiantDir/bin"
radiantCnf="$radiantDir/radiant.conf"
radiantTgz="v${radiantVer}".tar.gz
radiantGit="https://github.com/RadiantBlockchain/radiant-node/archive/refs/tags/$radiantTgz"
radiantSrc="$PWD/radiant-node-$radiantVer"
radiantBld="${radiantSrc}/build"

debug_step="wget $radiantTgz download"; progress_banner
if [[ ! -f "$radiantTgz" ]]; then
	wget_version=$(wget --version | head -n 1 | cut -d ' ' -f 3 | cut -c -4)
	if (( $(echo "$wget_version >= 1.16" | bc -l) )); then
		wget "${radiantGit}" -q --show-progress
	else
		wget "${radiantGit}"
	fi
	
else
	echo "$radiantTgz already downloaded"
fi
debug_location

debug_step="removing pre-existing source compile folder"; minor_progress
if [[ -d "$radiantSrc" ]]; then
	rm -r "$radiantSrc"
fi
debug_location

debug_step="decompress $radiantTgz"; progress_banner
if [[ -n $(command -v pv) ]]; then
	pv "$radiantTgz" | tar -xzf -
else
	tar -zxvf "$radiantTgz"
fi
debug_location

cd "$radiantSrc" || echo "unable to cd to $radiantSrc"

if [[ "$compile_upnpc" == 1 ]]; then 
	wget https://github.com/miniupnp/miniupnp/archive/refs/tags/miniupnpc_2_1.tar.gz
	tar -zxvf miniupnpc_2_1.tar.gz
	cd miniupnp-miniupnpc_2_1/miniupnpc
	make
	sudo make install
	cd "$radiantSrc" || echo "unable to cd to $radiantSrc"
fi

# compile zeromq
if [[ "$compile_zeromq" == 1 ]]; then
	if [[ $(command -v git) ]]; then
		git clone https://github.com/zeromq/libzmq
		cd libzmq 
		mkdir cmake-build && cd cmake-build
		cmake .. && make
		if [[ $(command -v sudo) ]]; then
			sudo make install && sudo ldconfig
		else
			make install && ldconfig
		fi
	else
		echo "must have git installed"
		script_exit
		unset script_exit
		exit 1
	fi
	cd "$radiantSrc" || echo "unable to cd to $radiantSrc"
fi

mkdir -p "$radiantBld"
cd "$radiantBld" || echo "cant cd to $radiantBld"

debug_step="cmake -GNinja"; progress_banner
if [[ "${cmake_gninja_noqt[*]}" =~ "$radiant_OS" ]]; then
	cmake -GNinja .. -DBUILD_RADIANT_QT=OFF 
elif [[ "${nowal_upnp_zmq_qt[*]}" =~ "$radiant_OS" ]]; then
	cmake -G Ninja .. -D BUILD_RADIANT_QT=OFF -D BUILD_BITCOIN_WALLET=OFF -D ENABLE_UPNP=OFF -D BUILD_BITCOIN_ZMQ=OFF
elif [[ "${wallet_disabled_array[*]}" =~ "$radiant_OS" ]]; then
	cmake -G Ninja .. -D BUILD_RADIANT_QT=OFF -D BUILD_BITCOIN_WALLET=OFF
elif [[ "$uname_OS" == OpenBSD ]]; then
	cmake -G Ninja .. -D BUILD_RADIANT_QT=OFF -D BUILD_BITCOIN_WALLET=OFF
elif  [[ "$uname_OS" == NetBSD ]]; then
	CC=/usr/pkg/gcc9/bin/gcc CXX=/usr/pkg/gcc9/bin/g++-4.2 cmake -G Ninja .. \
	-D BUILD_RADIANT_QT=OFF -D BUILD_BITCOIN_WALLET=OFF -DCMAKE_C_COMPILER=clang
	# -D CMAKE_C_COMPILER=/usr/pkg/gcc9/bin/gcc -D CMAKE_CXX_COMPILER=/usr/pkg/gcc9/bin/g++
else
	echo "error: $novo_OS not in configuration array"
fi

debug_step="ninja build"; progress_banner
ninja 
debug_location

debug_step="copying and stripping binaries into $radiantBin"; minor_progress
if [[ ! -d "$radiantBin" ]]; then mkdir "$radiantBin"; fi
cp src/radiantd "$radiantBin"/radiantd && strip "$radiantBin"/radiantd
cp src/radiant-cli "$radiantBin"/radiant-cli && strip "$radiantBin"/radiant-cli
cp src/radiant-tx "$radiantBin"/radiant-tx && strip "$radiantBin"/radiant-tx
debug_location

if [[ ! -f "$radiantCnf" ]]; then
	debug_step="creating conf"; progress_banner
	radiantUsr="$(xxd -l 16 -p /dev/urandom)"
	radiantRpc="$(xxd -l 20 -p /dev/urandom)"
	echo \
	"port=7332"$'\n'\
	"rpcport=7333"$'\n'\
	"rpcuser=$radiantUsr"$'\n'\
	"rpcpassword=$radiantRpc"$'\n'\
	"txindex=1"$'\n'\
	| tr -d ' ' > "$radiantCnf"
	debug_location
	cat "$radiantCnf"
fi

debug_step="binaries available in $radiantBin:"; minor_progress
ls -hal "$radiantBin"/radiant{-cli,-tx,d}
debug_location

if [[ "${wallet_disabled_array[*]}" =~ "$radiant_OS" ]]; then
	if [[ -f $(source /etc/os-release) ]]; then
		radiant_OS=$(source /etc/os-release; echo "$PRETTY_NAME")
	fi
	debug_step="wallet build is presently disabled on $radiant_OS"; minor_progress
	debug_step="please submit a pull request or comment on how to build the wallet"; minor_progress
	debug_step="to the repo at: https://github.com/bitsko/radiantconfig"; minor_progress
fi

echo $'\n'"to use:"
echo "$radiantBin/radiantd --daemon" 
echo "tail -f $radiantDir/debug.log" 
echo "$radiantBin/radiant-cli --help"

script_exit
unset -f script_exit
