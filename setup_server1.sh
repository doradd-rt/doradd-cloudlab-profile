# setup doradd-server
git clone https://github.com/doradd-rt/doradd-server.git 
pushd doradd-server
git submodule update --init
make dpdk
cd scripts && sudo ./hugepages.sh 
cd ../src && mkdir build && cd build
cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release
popd

# setup caladan repo
git clone https://github.com/doradd-rt/caladan
pushd caladan
sudo apt install -y make gcc cmake pkg-config libnl-3-dev libnl-route-3-dev libnuma-dev uuid-dev libssl-dev libaio-dev libcunit1-dev libclang-dev libncurses-dev meson python3-pyelftools
curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain=nightly-2024-01-30
. "$HOME/.cargo/env"
make submodules
popd
