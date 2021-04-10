#!/bin/bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -e # exit on error

# Build clang & LLVM cmake
LLVM_DEP_PACKAGES="build-essential make ninja-build git binutils-gold binutils-dev curl wget"
apt-get install -y $LLVM_DEP_PACKAGES


export CXX=g++
export CC=gcc
unset CFLAGS
unset CXXFLAGS

mkdir ~/build; cd ~/build
mkdir llvm_tools; cd llvm_tools
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/llvm-11.0.0.src.tar.xz
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/clang-11.0.0.src.tar.xz
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/compiler-rt-11.0.0.src.tar.xz
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/libcxx-11.0.0.src.tar.xz
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/libcxxabi-11.0.0.src.tar.xz
tar xf llvm-11.0.0.src.tar.xz
tar xf clang-11.0.0.src.tar.xz
tar xf compiler-rt-11.0.0.src.tar.xz
tar xf libcxx-11.0.0.src.tar.xz
tar xf libcxxabi-11.0.0.src.tar.xz
mv clang-11.0.0.src ~/build/llvm_tools/llvm-11.0.0.src/tools/clang
mv compiler-rt-11.0.0.src ~/build/llvm_tools/llvm-11.0.0.src/projects/compiler-rt
mv libcxx-11.0.0.src ~/build/llvm_tools/llvm-11.0.0.src/projects/libcxx
mv libcxxabi-11.0.0.src ~/build/llvm_tools/llvm-11.0.0.src/projects/libcxxabi

mkdir -p build-llvm/llvm; cd build-llvm/llvm
cmake -G "Ninja" \
      -DLIBCXX_ENABLE_SHARED=OFF -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
      -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="X86" \
      -DLLVM_BINUTILS_INCDIR=/usr/include ~/build/llvm_tools/llvm-11.0.0.src
ninja; ninja install

cd ~/build/llvm_tools
mkdir -p build-llvm/msan; cd build-llvm/msan
cmake -G "Ninja" \
      -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
      -DLLVM_USE_SANITIZER=Memory -DCMAKE_INSTALL_PREFIX=/usr/msan/ \
      -DLIBCXX_ENABLE_SHARED=OFF -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
      -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="X86" \
       ~/build/llvm_tools/llvm-11.0.0.src
ninja cxx; ninja install-cxx

# Install LLVMgold in bfd-plugins
mkdir /usr/lib/bfd-plugins
cp /usr/local/lib/libLTO.so /usr/lib/bfd-plugins
cp /usr/local/lib/LLVMgold.so /usr/lib/bfd-plugins

# install some packages
export LC_ALL=C
apt-get update
# apt install -y python-dev python3 python3-dev python3-pip autoconf automake libtool-bin python-bs4 # libclang-11.0-dev
apt install -y autoconf automake libtool-bin python-bs4

# install python3.8
# PYTHON_VERSION=3.8.6
# cd /tmp/
# curl -O https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz
# tar -xvf Python-$PYTHON_VERSION.tar.xz
# cd Python-$PYTHON_VERSION
# ./configure --enable-loadable-sqlite-extensions --enable-optimizations
# make -j install
# rm -r /tmp/Python-$PYTHON_VERSION.tar.xz /tmp/Python-$PYTHON_VERSION

# python3 -m pip install --upgrade pip
wget https://bootstrap.pypa.io/3.5/get-pip.py
python3 get-pip.py
python3 -m pip install networkx pydot pydotplus

# Install newer cmake.
# apt remove -y cmake
# wget https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5-Linux-x86_64.sh
# chmod +x cmake-3.14.5-Linux-x86_64.sh
# ./cmake-3.14.5-Linux-x86_64.sh --skip-license --prefix="/usr/bin"

# cd /afl/distance_calculator
# cmake -G Ninja ./
# cmake --build ./

# export CXX=clang++
# export CC=clang
# # build AFLGo
# cd /afl
# make clean all
# pushd llvm_mode; make clean all; popd
# export AFLGO=/afl
