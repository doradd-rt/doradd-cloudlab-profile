git clone https://github.com/doradd-rt/rpc-dpdk-client.git
cd rpc-dpdk-client
git submodule update --init
make dpdk
cd scripts && sudo ./hugepages.sh 
cd ../src && mkdir build && cd build
cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DYCSB=True -DEXPONENTIAL=True
cd ../../

# Prepare log
# TODO: add more
pushd scripts/gen-replay-log
g++ -O3 generate_ycsb_zipf.cc
./a.out -d uniform -c no_cont
popd
