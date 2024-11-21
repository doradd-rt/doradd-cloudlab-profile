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
sudo su - $GENIUSER -c "git clone https://github.com/doradd-rt/doradd-server.git" 
pushd doradd-server
sudo su - $GENIUSER -c "git submodule update --init"
sudo su - $GENIUSER -c "make dpdk"
sudo su - $GENIUSER -c "cd scripts && sudo ./hugepages.sh"
sudo su - $GENIUSER -c "cd ../src && mkdir build && cd build"
sudo su - $GENIUSER -c "cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release"
popd
