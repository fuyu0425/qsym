#!/bin/bash

# check ptrace_scope for PIN
if ! grep -qF "0" /proc/sys/kernel/yama/ptrace_scope; then
  echo "Please run 'echo 0|sudo tee /proc/sys/kernel/yama/ptrace_scope'"
  exit -1
fi

git submodule init
git submodule update

# install system deps
sudo apt-get update
sudo apt-get install -y libc6 libstdc++6 linux-libc-dev gcc-multilib \
  llvm-dev g++ g++-multilib python python-pip \
  lsb-release

# install z3
pushd third_party/z3
rm -rf build
./configure --prefix=/usr/local/qsym
pushd build
make -j$(nproc)
sudo make install
popd
rm -rf build
./configure --x86 --prefix=/usr/local/qsym32
cd build
make -j$(nproc)
sudo make install
popd

# build test directories
pushd tests
python build.py
popd

cat <<EOM
Please install qsym by using (or check README.md):

  $ virtualenv venv
  $ source venv/bin/activate
  $ pip install .
EOM
