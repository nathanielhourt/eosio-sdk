#!/bin/bash

git clone https://github.com/EOSIO/eos --recursive
mkdir eosbuild
cd eosbuild
cmake ../eos -DCMAKE_INSTALL_PREFIX=../eosiosdk
make -j4 install
cd ..

git clone --depth 1 --single-branch --branch release_40 https://github.com/llvm-mirror/llvm.git
cd llvm/tools
git clone --depth 1 --single-branch --branch release_40 https://github.com/llvm-mirror/clang.git
mkdir ../../llvmbuild
cd ../../llvmbuild
cmake -DCMAKE_INSTALL_PREFIX=../eosiosdk -DLLVM_TARGETS_TO_BUILD= -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly -DCMAKE_BUILD_TYPE=Release ../llvm
make -j4 install-llvm-config install-clang install-llvm-link install-llc
cd ..

git clone https://github.com/WebAssembly/binaryen
mkdir binaryenbuild
cd binaryenbuild
cmake -DCMAKE_INSTALL_PREFIX=../eosiosdk -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-Wno-error=implicit-fallthrough=" ../binaryen
make -j4 s2wasm
cp bin/s2wasm ../eosiosdk/bin
cd ..

cp -r eoslib eosiosdk/include
cp eoscpp eosiosdk/bin
