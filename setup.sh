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
sudo su - $GENIUSER -c "wget https://content.mellanox.com/ofed/MLNX_OFED-24.04-0.6.6.0/MLNX_OFED_LINUX-24.04-0.6.6.0-ubuntu22.04-x86_64.tgz --no-check-certificate"
sudo su - $GENIUSER -c "tar -xvzf MLNX_OFED_LINUX-24.04-0.6.6.0-ubuntu22.04-x86_64.tgz"
pushd MLNX_OFED_LINUX-24.04-0.6.6.0-ubuntu22.04-x86_64
sudo su - $GENIUSER -c "./mlnxofedinstall --force --upstream-libs --dpdk"
sudo su - $GENIUSER -c "/etc/init.d/openibd restart"
popd
popd

# TODO: clone ppopp-artifact repo to make it consistent and unaffected by future changes
