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
sudo apt install -y meson python3-pyelftools cmake pkg-config htop

pushd /users/$GENIUSER
sudo wget https://content.mellanox.com/ofed/MLNX_OFED-24.04-0.6.6.0/MLNX_OFED_LINUX-24.04-0.6.6.0-ubuntu22.04-x86_64.tgz --no-check-certificate
sudo tar -xvzf MLNX_OFED_LINUX-24.04-0.6.6.0-ubuntu22.04-x86_64.tgz
pushd MLNX_OFED_LINUX-24.04-0.6.6.0-ubuntu22.04-x86_64
sudo ./mlnxofedinstall --force --upstream-libs --dpdk
sudo /etc/init.d/openibd restart
popd
popd

sleep 5

# TODO: clone ppopp-artifact repo to make it consistent and unaffected by future changes

pushd /users/$GENIUSER
sudo git clone https://github.com/doradd-rt/rpc-dpdk-client.git

pushd rpc-dpdk-client
sudo git submodule update --init
sudo make dpdk

pushd scripts
sudo ./hugepages.sh
popd

pushd src 
sudo mkdir build
pushd build
sudo cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DYCSB=True -DEXPONENTIAL=True
popd
popd

# Prepare log
# TODO: add more
pushd scripts/gen-replay-log
sudo g++ -O3 generate_ycsb_zipf.cc
sudo ./a.out -d uniform -c no_cont
sudo ./a.out -d zipfian -s 0.50 -c no_cont
sudo ./a.out -d zipfian -s 0.80 -c no_cont
sudo ./a.out -d zipfian -s 0.90 -c no_cont
sudo ./a.out -d zipfian -s 0.95 -c no_cont
sudo ./a.out -d zipfian -s 0.99 -c no_cont
popd

popd

sudo chown -R $GENIUSER /users/$GENIUSER
