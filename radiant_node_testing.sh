#!/usr/bin/env bash

# compile the latest version of radiant node

# wget -N https://raw.githubusercontent.com/bitsko/radiantconfig/main/radiant_node_compile.sh && chmod +x radiant_node_compile.sh && ./radiant_node_compile.sh
echo "script broken"; exit 1
progress_banner(){ echo $'\n\n'"${radiantTxt} ${debug_step} ${radiantTxt}"$'\n\n'; sleep 2; }
minor_progress(){ echo "	***** $debug_step *****"; sleep 1; }
keep_clean(){ if [[ "$frshDir" == 1 ]]; then rm -r "$radiantDir" 2>/dev/null; fi; }

debug_location(){
	if [[ "$?" != 0 ]]; then
		echo $'\n\n'"$debug_step has failed!"$'\n\n'
		keep_clean
#		if ps -p $tail_pid > /dev/null; then 
#			kill "$tail_pid"
#		fi
#		if [[ -s "$radiantSrc/log" ]]; then
#			tail -n 10 "$radiantSrc/log"
#			echo $'\n'"log available at $radiantSrc/log"$'\n'
#		fi
		script_exit
		exit 1
	fi; }

script_exit(){ unset \
		radiantUsr radiantRpc radiantCpu radiantAdr radiantDir radiantCnf radiantVer radiantTgz \
		radiantTxt radiantSrc radiantNum archos_array deb_os_array armcpu_array x86cpu_array \
		bsdpkg_array redhat_array cpu_type pkg_Err uname_OS radiantPrc debug_step frshDir \
		radiant_OS radiantBar keep_clean bsd__pkg_array_ compile_bdb53 radiantTxt tail_pid \
		progress_banner minor_progress compile_boost wallet_disabled radiantLog radiantGit; }

radiantTxt="***********************"
radiantBar="$radiantTxt $radiantTxt $radiantTxt"
radiantBsd=0
compile_bdb53=0
compile_boost=0
wallet_disabled=0

echo "$radiantBar"; debug_step="radiant node compile script"; progress_banner

debug_step="declare arrays with bash v4+"
declare -a bsdpkg_array=( freebsd OpenBSD NetBSD )
declare -a redhat_array=( fedora centos rocky amzn )
declare -a deb_os_array=( debian ubuntu raspbian linuxmint pop )
declare -a archos_array=( manjaro-arm manjaro endeavouros arch )
declare -a armcpu_array=( aarch64 aarch64_be armv8b armv8l armv7l )
declare -a x86cpu_array=( i686 x86_64 i386 ) # amd64
debug_location
cpu_type="$(uname -m)"
uname_OS="$(uname -s)"
radiant_OS=$(if [[ -f /etc/os-release ]]; then source /etc/os-release; echo "$ID";	fi; )
debug_step="find the operating system type"
if [[ -z "$radiant_OS" ]]; then radiant_OS="$uname_OS"; fi
if [[ "$radiant_OS" == "Linux" ]]; then echo "Linux distribution type unknown; cannot check for dependencies"; fi
debug_step="compiling for: $radiant_OS $cpu_type"; progress_banner; echo "$radiantBar"

debug_step="dependencies installation"; progress_banner
if [[ "${deb_os_array[*]}" =~ "$radiant_OS" ]]; then
	sudo apt update
	sudo apt -y upgrade
	declare -a dpkg_pkg_array_=( build-essential libtool pkg-config  libcurl4-openssl-dev \
		libncurses-dev autoconf autogen automake libevent-dev libminiupnpc-dev \
		bsdmainutils python3 libevent-dev libboost-system-dev libboost-filesystem-dev \
		libboost-chrono-dev libboost-program-options-dev libboost-test-dev automake \
		libboost-thread-dev libsqlite3-dev libqrencode-dev libdb-dev libdb++-dev \
		libssl-dev miniupnpc bc curl jq wget libzmq3-dev xxd pv help2man ninja-build )
	while read -r line; do
        	if ! dpkg -s "$line" &> /dev/null; then
			dpkg_to_install+=( "$line" )
		fi
       	done <<<$(printf '%s\n' "${dpkg_pkg_array_[@]}")
	unset dpkg_pkg_array_
	if [[ -n "${dpkg_to_install[*]}" ]]; then
                sudo apt -y install ${dpkg_to_install[*]}
                debug_location
		unset dpkg_to_install
        fi
	if [[ "${armcpu_array[*]}" =~ "$cpu_type" ]]; then
		if ! dpkg -s g++ &> /dev/null; then
			sudo apt -y install g++-arm-linux-gnueabihf
			debug_location
		fi
	fi
elif [[ "${archos_array[*]}" =~ "$radiant_OS" ]]; then
	sudo pacman -Syu
	declare -a arch_pkg_array_=( boost boost-libs libevent libnatpmp binutils libtool m4 make \
		automake autoconf zeromq gzip curl sqlite qrencode nano fakeroot gcc grep pkgconf \
		sed miniupnpc jq wget bc vim pv xxd ncurses help2man ninja )
	
  #  ninja-build )

	while read -r line; do
        	if ! pacman -Qi "$line" &> /dev/null; then
			arch_to_install+=( "$line" )
			debug_location
		fi
	done <<<$(printf '%s\n' "${arch_pkg_array_[@]}")
	unset arch_pkg_array_
        if [[ -n "${arch_to_install[*]}" ]]; then
       	        sudo pacman --noconfirm -Sy ${arch_to_install[*]}
       		debug_location
                unset arch_to_install
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
        sudo dnf update
        if [[ "$radiant_OS" == fedora  || "$radiant_OS" == amzn ]]; then
		declare -a rhat_pkg_array_=( gcc-c++ libtool make autoconf automake openssl-devel \
			libevent-devel boost-devel libdb-devel libdb-cxx-devel miniupnpc-devel \
			qrencode-devel gzip jq wget bc vim sed grep zeromq-devel pv )
        elif [[ "$radiant_OS" == centos || "$radiant_OS" == rocky ]]; then
	                declare -a rhat_pkg_array_=( libtool make autoconf automake openssl-devel \
                        libevent-devel boost-devel gcc-c++ gzip jq wget bc vim sed grep libuuid-devel )
	                # miniupnpc-devel qrencode-devel zeromq-devel libdb-devel pv
	else
		echo "$uname_OS unsupported"
		exit 1
	fi
	while read -r line; do
                if ! rpm -qi "$line" &> /dev/null; then
                        rhat_to_install+=( "$line" )
                        debug_location
                fi
        done <<<$(printf '%s\n' "${rhat_pkg_array_[@]}")
        unset rhat_pkg_array_
        if [[ -n "${rhat_to_install[*]}" ]]; then
               	if [[ -n $(command -v dnf) ]]; then
			sudo dnf install -y ${rhat_to_install[*]}
                else
			sudo yum install -y ${rhat_to_install[*]}
		fi
		debug_location
		unset rhat_to_install
        fi
        if [[ "${armcpu_array[*]}" =~ "$cpu_type" ]]; then
                if ! rpm -qi arm-none-eabi-binutils &> /dev/null; then
                        sudo dnf install -y arm-none-eabi-binutils
                        debug_location
                fi
                if ! rpm -qi arm-none-eabi-gcc &> /dev/null; then
                        sudo dnf install -y arm-none-eabi-gcc
                        debug_location
                fi
        fi
elif [[ "${bsdpkg_array[*]}" =~ "$radiant_OS" ]]; then
	radiantBsd=1
	if [[ "$uname_OS" == OpenBSD ]]; then
		# compile_bdb53=1
		# compile_boost=1
		declare -a bsd__pkg_array_=( libevent libqrencode pkgconf miniupnpc jq \
			curl wget gmake python-3.9.13 sqlite3 nano zeromq openssl boost \
			libtool-2.4.2p2 autoconf-2.71 automake-1.16.3 vim-8.2.4600-no_x11 pv )
			# llvm boost git g++-11.2.0p2 gcc-11.2.0p2
	elif [[ "$uname_OS" == NetBSD ]]; then
		if [[ -z $(command -v pkgin) ]]; then
			pkg_add pkgin
		fi
		declare -a bsd__pkg_array_=( libtool libevent qrencode pkgconf miniupnpc \
			jq curl wget gmake python39 sqlite3 boost nano zeromq openssl autoconf \
			automake ca-certificates boost-libs readline vim llvm clang pv )
			# db5 llvm clang gcc9 R-BH-1.75.0.0
	elif [[ "$radiant_OS" == freebsd ]]; then
		pkg upgrade -y
		declare -a bsd__pkg_array_=( boost-all libevent autotools libqrencode curl \
			octave-forge-zeromq libnpupnp nano fakeroot pkgconf miniupnpc gzip \
			jq wget db5 libressl gmake python3 sqlite3 binutils gcc clang vim pv )
	else
		echo "$radiant_OS bsd distro not supported"
	fi
	while read -r line; do 
		if ! command -v "$line" >/dev/null; then
			pkg_to_install_+=( "$line" )
		fi
	done <<<$(printf '%s\n' "${bsd__pkg_array_[@]}")
	
	if [[ -n "${pkg_to_install_[*]}" ]]; then
		if [[ "$radiant_OS" == freebsd ]]; then
			pkg install -y ${pkg_to_install_[*]}
			debug_location
		elif [[ "$uname_OS" == "OpenBSD" ]] || [[ "$uname_OS" == "NetBSD" ]]; then
			if [[ -n $(command -v pkgin) ]]; then
				pkgin install ${pkg_to_install_[*]}
			else
				pkg_add ${pkg_to_install_[*]}
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
# end dependency installation script

debug_step="curl-ing the release version"; minor_progress
radiantDir="$HOME/.radiant"
radiantBin="$radiantDir/bin"
radiantCnf="$radiantDir/radiant.conf"
if [[ -n $(command -v jq) && -n $(command -v curl) ]]; then
	radiantVer="$(curl -s https://api.github.com/repos/RadiantBlockchain/radiant-node/releases/latest |jq .tag_name | sed 's/"//g;s/v//g')"
else 
	echo "*** jq not installed, dependencies installation failed"
	exit 1
fi
debug_location
radiantTgz="v${radiantVer}".tar.gz
radiantGit="https://github.com/RadiantBlockchain/radiant-node/archive/refs/tags/$radiantTgz"
radiantSrc="$PWD/radiant-node-$radiantVer"
radiantBld="${radiantSrc}/build"
frshDir=0

debug_step="making directories, backing up .radiant folder if present"; minor_progress
if [[ ! -d "$radiantDir" ]]; then
	mkdir "$radiantDir"
	debug_location
	frshDir=1
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

debug_step="wget $radiantTgz download"; progress_banner
if [[ ! -f "$radiantTgz" ]]; then
	wget "${radiantGit}" -q --show-progress
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

# if [[ -f "$radiantSrc/log" ]]; then
#	mv "$radiantSrc/log $radiantSrc/log$EPOCHSECONDS"
# fi
# touch "$radiantSrc/log"

# tail -f log & 
# tail_pid=$!

mkdir -p "$radiantBld"
cd "$radiantBld" || echo "cant cd to $radiantBld"
debug_step="ninja package"; progress_banner
cmake -GNinja .. -DBUILD_RADIANT_QT=OFF
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
ls "$radiantBin"
debug_location
if [[ -s "$radiantSrc/log" ]]; then
	sed -n '/Options used to compile and link:/,/Making all in src/p' "$radiantSrc/log"
	if [[ "$?" != 0 ]]; then
		tail -n 10 "$radiantSrc/log"
	fi
fi
if [[ "$wallet_disabled" == 1 ]]; then
	if [[ -n $(source /etc/os-release; echo "$PRETTY_NAME") ]]; then
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
# if ps -p $tail_pid > /dev/null; then
#	kill "$tail_pid"
# fi
script_exit
unset -f script_exit
