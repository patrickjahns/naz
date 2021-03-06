#!/usr/bin/env bash
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    set -euo pipefail
else
    # Bash 4.3 and older chokes on empty arrays with set -u.
    set -eo pipefail
fi
shopt -s nullglob globstar

export DEBIAN_FRONTEND=noninteractive && \
apt -y update && \
apt -y install python3.7 && \
apt -y install python-pip python3-pip nano wget unzip curl screen pandoc && \
apt -y install python3-dev && \
apt -y install python3.7-dev

# NB: do not install docker from snap; it is broken
# https://github.com/docker/for-linux/issues/290
apt -y remove docker docker-engine docker.io containerd runc docker-ce docker-ce-cli; \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
apt-key fingerprint 0EBFCD88 && \
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) test" && \
apt -y update; apt -y autoremove && \
apt -y install docker-ce && \
usermod -aG docker $(whoami) && \
pip install -U docker-compose

wget https://github.com/komuw/naz/archive/master.zip && \
unzip master.zip && \
mv naz-master/ naz && \
cd naz/benchmarks


# A. SMSC SERVER
# 1. Add firewall to the server that has these ports open: 22, 2775, 6379, 9000
# 2. start screen
python3.7 -m pip install -U -e ..[dev,test,benchmarks]
export REDIS_PASSWORD=hey_NSA && python3.7 smpp_n_broker_servers.py &>/dev/null &
disown

# A. NAZ-CLI
# 1. Add firewall to the server that has these ports open: 22, 2775, 6379, 9000
# 2. start screen
# 3. edit `compose.env`(if neccesary)
docker-compose up --build &>/dev/null &
disown
