# setup doradd-server
git clone https://github.com/doradd-rt/doradd-server.git 
pushd doradd-server
git submodule update --init
make dpdk
cd scripts && sudo ./hugepages.sh 
cd ../src && mkdir build && cd build
cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release
popd
