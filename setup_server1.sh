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

pushd /users/$GENIUSER

# setup doradd-server
sudo su -c $GENIUSER -c "git clone https://github.com/doradd-rt/doradd-server.git" 
pushd doradd-server
sudo su -c $GENIUSER -c "git submodule update --init"
sudo su -c $GENIUSER -c "make dpdk"
sudo su -c $GENIUSER -c "cd scripts && sudo ./hugepages.sh"
sudo su -c $GENIUSER -c "cd ../src && mkdir build && cd build"
sudo su -c $GENIUSER -c "cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release"
popd

# setup caladan repo
sudo su -c $GENIUSER -c "git clone https://github.com/doradd-rt/caladan"
pushd caladan
sudo su -c $GENIUSER -c "sudo apt install -y make gcc cmake pkg-config libnl-3-dev libnl-route-3-dev libnuma-dev uuid-dev libssl-dev libaio-dev libcunit1-dev libclang-dev libncurses-dev meson python3-pyelftools"
sudo su -c $GENIUSER -c "curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain=nightly-2024-01-30"
sudo su -c $GENIUSER -c ". "$HOME/.cargo/env""
sudo su -c $GENIUSER -c "make submodules"
popd
