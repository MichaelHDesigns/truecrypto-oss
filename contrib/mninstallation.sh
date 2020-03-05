#!/bin/bash
# truecrypto-oss installer for TDC blockchain
# https://raw.githubusercontent.com/truedividendcryptocurrency/truecrypto-oss/master/contrib/mninstallation.sh

TMP_FOLDER=$(mktemp -d)
CONFIG_FILE='tdc.conf'
CONFIG_FOLDER='/root/.tdc'
COIN_DAEMON='tdcd'
COIN_CLI='tdc-cli'
COIN_PATH='/usr/local/bin/'
COIN_REPO='https://github.com/truedividendcryptocurrency/truecrypto-oss.git'
COIN_NAME='truecrypto-oss'
COIN_PORT=17281
BOOTSTRAP_DOWNLOAD='https://github.com/truedividendcryptocurrency/truecrypto-blockchain-bootstrap/releases/download/590001/bootstrap.dat'

NODEIP=$(curl -s4 icanhazip.com)

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

OS_VERSION='unsupported'

function compile_node() {
  echo -e "Preparing to compile $COIN_NAME..."
  echo -e "${RED}WARNING:${NC} this may take a long time..."
  git clone $COIN_REPO $TMP_FOLDER >/dev/null 2>&1
  compile_error
  cd $TMP_FOLDER
  git checkout latest >/dev/null 2>&1
  compile_error
  chmod +x ./autogen.sh 
  chmod +x ./share/genbuild.sh
  chmod +x ./src/leveldb/build_detect_platform
  ./autogen.sh
  compile_error
  ./configure --without-gui --disable-tests
  compile_error
  make
  compile_error
  make install
  compile_error
  strip $COIN_PATH$COIN_DAEMON $COIN_PATH$COIN_CLI
  cd - >/dev/null 2>&1
  rm -rf $TMP_FOLDER >/dev/null 2>&1
  clear
}


function configure_systemd() {
  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target

[Service]
User=root
Group=root

Type=forking
#PIDFile=$CONFIG_FOLDER/$COIN_NAME.pid

ExecStart=$COIN_PATH$COIN_DAEMON -daemon -conf=$CONFIG_FOLDER/$CONFIG_FILE -datadir=$CONFIG_FOLDER
ExecStop=-$COIN_PATH$COIN_CLI -conf=$CONFIG_FOLDER/$CONFIG_FILE -datadir=$CONFIG_FOLDER stop

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  systemctl start $COIN_NAME.service
  systemctl enable $COIN_NAME.service >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
}


function download_bootstrap() {
	cd $CONFIG_FOLDER
	wget $BOOTSTRAP_DOWNLOAD
}


function create_config() {
  mkdir $CONFIG_FOLDER >/dev/null 2>&1
  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $CONFIG_FOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
txindex=1
port=$COIN_PORT
EOF
}


function create_key() {
  echo -e "Input your existing ${RED}MASTERNODE PRIVATE KEY${NC} or leave it blank"
  echo -e "and just press ENTER to generate a new one for you:"
  read -e COINKEY
  if [[ -z "$COINKEY" ]]; then
    $COIN_PATH$COIN_DAEMON -daemon
    sleep 30
    if [ -z "$(ps axo cmd:100 | grep $COIN_DAEMON)" ]; then
     echo -e "${RED}$COIN_NAME server could not start. Check /var/log/syslog for errors.{$NC}"
     exit 1
    fi
    COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
    if [ "$?" -gt "0" ];
      then
      echo -e "${RED}Wallet not fully loaded, waiting 30 seconds then trying again to generate the MASTERNODE PRIVATE KEY${NC}"
      sleep 30
      COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
    fi
    $COIN_PATH$COIN_CLI stop
  fi
  clear
}


function update_config() {
  sed -i 's/daemon=1/daemon=0/' $CONFIG_FOLDER/$CONFIG_FILE
  cat << EOF >> $CONFIG_FOLDER/$CONFIG_FILE
logintimestamps=1
maxconnections=256
#bind=$NODEIP
masternode=1
externalip=$NODEIP:$COIN_PORT
masternodeprivkey=$COINKEY
EOF
}


function enable_firewall() {
  echo -e "Installing and setting up firewall to allow connections on port ${GREEN}$COIN_PORT${NC}"
  ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  ufw allow ssh comment "SSH" >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
  sleep 5
  clear
}


function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]
    then
      echo -e "${GREEN}More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
}


function compile_error() {
  if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
    exit 1
  fi
}


function checks() {
  if [[ $(lsb_release -d) == *18.04* ]]; then
    OS_VERSION='18.04'
  fi

  if [[ $(lsb_release -d) == *16.04* ]]; then
    OS_VERSION='16.04'
  fi

  if [ $OS_VERSION == "unsupported" ]; then
    echo -e "${RED}You are not running Ubuntu 18.04 or 16.04. Installation is cancelled.${NC}"
    exit 1
  fi

  if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}$0 must be run as root.${NC}"
    exit 1
  fi

  if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMON" ]; then
    echo -e "${RED}$COIN_NAME is already installed.${NC}"
    exit 1
  fi
}


function prepare_system() {
  echo -e "Preparing the system to install ${GREEN}$COIN_NAME${NC} masternode..."
  apt-get update >/dev/null 2>&1
  DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
  DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
  apt install -y software-properties-common >/dev/null 2>&1
  echo -e "${GREEN}Adding bitcoin PPA repository..."
  apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
  echo -e "Installing required packages, it may take some time to finish.${NC}"
  apt-get update >/dev/null 2>&1
  if [ "$OS_VERSION" == "18.04" ]; then
    apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make build-essential \
    libtool autoconf libssl1.0-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
    libboost-system-dev libboost-test-dev libboost-thread-dev automake git libdb4.8-dev bsdmainutils libdb4.8++-dev \
    libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libzmq5 >/dev/null 2>&1
    if [ "$?" -gt "0" ]; then
      echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
      echo "apt-get update"
      echo "apt -y install software-properties-common"
      echo "apt-add-repository -y ppa:bitcoin/bitcoin"
      echo "apt-get update"
      echo "apt install -y make build-essential libtool autoconf libssl1.0-dev libboost-dev libboost-chrono-dev \
        libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev \
        automake git libdb4.8-dev bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libzmq5"
      exit 1
    fi
  fi
  if [ "$OS_VERSION" == "16.04" ]; then
    apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make build-essential \
    libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
    libboost-system-dev libboost-test-dev libboost-thread-dev automake git libdb4.8-dev bsdmainutils libdb4.8++-dev \
    libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libzmq5 >/dev/null 2>&1
    if [ "$?" -gt "0" ]; then
      echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
      echo "apt-get update"
      echo "apt -y install software-properties-common"
      echo "apt-add-repository -y ppa:bitcoin/bitcoin"
      echo "apt-get update"
      echo "apt install -y make build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev \
        libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev \
        automake git libdb4.8-dev bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libzmq5"
      exit 1
    fi
  fi

  clear
}


function create_swap() {
  echo -e "Checking if swap space is needed..."
  PHYMEM=$(free -g|awk '/^Mem:/{print $2}')
  SWAP=$(free -g|awk '/^Swap:/{print $2}')
  if [ "$PHYMEM" -lt "2" ]; then
    if [ "$SWAP" -eq "0" ]; then
      echo -e "${GREEN}Server is running with less than 2G of RAM without SWAP, creating 2G swap file.${NC}"
      SWAPFILE=$(mktemp)
      dd if=/dev/zero of=$SWAPFILE bs=1024 count=2M
      chmod 600 $SWAPFILE
      mkswap $SWAPFILE
      swapon -a $SWAPFILE
    else
      echo -e "${GREEN}Existing swap file found, proceeding...${NC}"
      sleep 5
    fi
  else
    echo -e "${GREEN}Server running with at least 2G of RAM, no swap needed.${NC}"
    sleep 5
  fi
  clear
}


function important_information() {
  echo
  echo -e "================================================================================================================================"
  echo -e "$COIN_NAME masternode is online and listening for connections on port ${RED}$COIN_PORT${NC}."
  echo -e "Configuration file is: ${RED}$CONFIG_FOLDER/$CONFIG_FILE${NC}"
  echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
  echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
  echo -e "VPS IP:PORT ${RED}$NODEIP:$COIN_PORT${NC}"
  echo -e "MASTERNODE PRIVATE KEY is: ${RED}$COINKEY${NC}"
  echo -e "Please check ${RED}$COIN_NAME${NC} is running with the following command: ${RED}systemctl status $COIN_NAME.service${NC}"
  echo -e "================================================================================================================================"
}


function setup_node() {
  get_ip
  create_config
  download_bootstrap
  create_key
  update_config
  enable_firewall
  important_information
  configure_systemd
}


##### Main #####
clear
checks
prepare_system
create_swap
compile_node
setup_node