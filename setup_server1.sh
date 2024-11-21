#!/bin/bash
set -x

# Might not be on the local cluster, so need to use the urn to
# see who the actual creator is.
#
GENIUSER=`geni-get user_urn | awk -F+ '{print $4}'`
if [ $? -ne 0 ]; then
echo "ERROR: could not run geni-get user_urn!"
exit 1
fi

sudo apt update
sudo apt install -y meson python3-pyelftools cmake pkg-config

pushd /users/$GENIUSER
sudo wget https://content.mellanox.com/ofed/MLNX_OFED-24.04-0.6.6.0/MLNX_OFED_LINUX-24.04-0.6.6.0-ubuntu22.04-x86_64.tgz --no-check-certificate
sudo tar -xvzf MLNX_OFED_LINUX-24.04-0.6.6.0-ubuntu22.04-x86_64.tgz
pushd MLNX_OFED_LINUX-24.04-0.6.6.0-ubuntu22.04-x86_64
sudo ./mlnxofedinstall --force --upstream-libs --dpdk
sudo /etc/init.d/openibd restart
popd
popd

pushd /users/$GENIUSER

# setup doradd-server
sudo git clone https://github.com/doradd-rt/doradd-server.git

pushd doradd-server

sudo git submodule update --init
sudo make dpdk
pushd scripts
sudo ./hugepages.sh
popd

pushd src 
sudo mkdir build
pushd build
sudo cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release
popd
popd

popd

# setup caladan repo
sudo git clone https://github.com/doradd-rt/caladan
pushd caladan
sudo apt install -y make gcc cmake pkg-config libnl-3-dev libnl-route-3-dev libnuma-dev uuid-dev libssl-dev libaio-dev libcunit1-dev libclang-dev libncurses-dev meson python3-pyelftools
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain=nightly-2024-01-30
sudo su - $GENIUSER -c ". "$HOME/.cargo/env""
sudo make submodules
popd
