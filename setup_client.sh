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
sudo su - $GENIUSER -c "git clone https://github.com/doradd-rt/rpc-dpdk-client.git"
sudo su - $GENIUSER -c "cd rpc-dpdk-client"
sudo su - $GENIUSER -c "git submodule update --init"
sudo su - $GENIUSER -c "make dpdk"
sudo su - $GENIUSER -c "cd scripts && sudo ./hugepages.sh"
sudo su - $GENIUSER -c "cd ../src && mkdir build && cd build"
sudo su - $GENIUSER -c "cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DYCSB=True -DEXPONENTIAL=True"
sudo su - $GENIUSER -c "cd ../../"

# Prepare log
# TODO: add more
pushd scripts/gen-replay-log
sudo su - $GENIUSER -c "g++ -O3 generate_ycsb_zipf.cc"
sudo su - $GENIUSER -c "./a.out -d uniform -c no_cont"
popd
popd
