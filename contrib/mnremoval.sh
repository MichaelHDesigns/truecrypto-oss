#!/bin/bash
# truecrypto-oss auto uninstaller for mninstallation script
# https://raw.githubusercontent.com/truedividendcryptocurrency/truecrypto-oss/master/contrib/mnremoval.sh

CONFIG_FOLDER='/root/.tdc'
COIN_DAEMON='tdcd'
COIN_CLI='tdc-cli'
COIN_TX='tdc-tx'
COIN_PATH='/usr/local/bin/'
COIN_NAME='truecrypto-oss'

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}$0 must be run as root.${NC}"
  exit 1
fi

if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMON" ] || [ -e "/etc/systemd/system/$COIN_NAME.service" ]; then
  echo -e "Stopping ${GREEN}$COIN_NAME${NC} masternode service..."
  systemctl stop $COIN_NAME.service
  echo -e "Removing ${GREEN}$COIN_NAME${NC} masternode service..."
  systemctl disable $COIN_NAME.service >/dev/null 2>&1
  rm /etc/systemd/system/$COIN_NAME.service
  systemctl daemon-reload
  sleep 3
  echo -e "Deleting ${GREEN}$COIN_NAME${NC} binaries..."
  rm $COIN_PATH$COIN_DAEMON
  rm $COIN_PATH$COIN_CLI
  rm $COIN_PATH$COIN_TX
  echo -e "${GREEN}Done!${NC}"
  exit 0
else
  echo -e "${RED}Cannot find ${GREEN}$COIN_NAME${RED} installation.${NC}"
  exit 1
fi