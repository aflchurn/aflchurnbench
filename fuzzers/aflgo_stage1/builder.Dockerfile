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

ARG parent_image
FROM $parent_image

# Add and compile AFLChurn
# Set AFL_NO_X86 to skip flaky tests.

ADD generate_distance.sh /out/
# ADD aflgo /afl
ADD patch.diff /
RUN git clone https://github.com/aflgo/aflgo.git /afl

RUN cd /afl && \
    git checkout cd9bca7e4cba9038f6e7e81f3938f379c754fc5a && \
    INITIAL_CXXFLAGS=$CXXFLAGS && \
    INITIAL_CFLAGS=$CFLAGS && \
    unset CFLAGS CXXFLAGS && \
    git apply /patch.diff && \
    scripts/build/aflgo-build.sh && \
    CXXFLAGS=$INITIAL_CXXFLAGS && \
    CFLAGS=$INITIAL_CFLAGS

RUN INITIAL_CXXFLAGS=$CXXFLAGS && \
    INITIAL_CFLAGS=$CFLAGS && \
    unset CFLAGS CXXFLAGS && \
    cd /afl && \
    AFL_NO_X86=1 CXX=clang++ CC=clang LLVM_CONFIG=llvm-config make clean all && \
    cd llvm_mode && \
    AFL_NO_X86=1 CXX=clang++ CC=clang LLVM_CONFIG=llvm-config make clean all && \
    touch /out/preprocessing && \
    CXXFLAGS=$INITIAL_CXXFLAGS && \
    CFLAGS=$INITIAL_CFLAGS


# Use afl_driver.cpp from LLVM as our fuzzing library.
# clang -Wno-pointer-sign -c /afl/llvm_mode/afl-llvm-rt.o.c -I/afl && \
RUN apt-get update && \
    apt-get install wget -y && \
    wget https://raw.githubusercontent.com/llvm/llvm-project/5feb80e748924606531ba28c97fe65145c65372e/compiler-rt/lib/fuzzer/afl/afl_driver.cpp -O /afl/afl_driver.cpp && \
    clang++ -stdlib=libc++ -std=c++11 -O2 -c /afl/afl_driver.cpp && \
    ar r /libAFL.a *.o
