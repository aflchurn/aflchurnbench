#!/bin/bash
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# Developed by Xiaogang Zhu <rosenzhu@hotmail.com> and Marcel Boehme <marcel.boehme@monash.edu>
# For running in docker


# crash test cases: 
# e.g., $EXPERIMENT_FOLDERS/openssl_x509-afl/trial-753301/corpus/crashes/id:*
EXPERIMENT_FOLDERS=/data
BUG_FOLDER_NAME=buglogs
OUT_LOG_DIR=$EXPERIMENT_FOLDERS/$BUG_FOLDER_NAME

IFS=$'\n'
mkdir -p $OUT_LOG_DIR

################ get original logs ################

for test_fuzzer in $(ls -1d $EXPERIMENT_FOLDERS/* | rev | cut -d- -f1 | rev | sort | uniq); do
  if [ "$test_fuzzer" = "$OUT_LOG_DIR" ]; then
    continue
  fi

  for trial in $(ls -1d ${EXPERIMENT_FOLDERS}/${BENCHMARK}-${test_fuzzer}/trial*); do
    # check if corpus-archive*.tar.gz exists; if so, unzip the last one
    if [ -f "$trial/corpus/corpus-archive-0001.tar.gz" ]; then
      corpus_id=$(ls -1d $trial/corpus/corpus-archive-*.tar.gz | rev | cut -d- -f1 | rev | cut -d. -f1 | sort | tail -n1)
      tar -zxf $trial/corpus/corpus-archive-${corpus_id}.tar.gz -C $trial/corpus
      if [ -f "$trial/corpus/corpus/plot_data" ]; then
        mv $trial/corpus/corpus/plot_data $trial/corpus/.
        chmod 777 $trial/corpus/plot_data
      fi
      if [ -d "$trial/corpus/corpus/crashes" ]; then
        mv $trial/corpus/corpus/crashes $trial/corpus/.
        chmod 777 -R $trial/corpus/crashes
      fi
      
      rm -rf $trial/corpus/corpus
    fi
    
    if [ ! -d "$trial/corpus/crashes" ]; then
        continue
    fi
    for cf in $(ls -1d $trial/corpus/crashes/id*); do
        if [ ! -f "$cf" ]; then
            continue
        fi
        echo ">>> $cf"
        python3 /out/asan_symbolize.py / < <(/out/$FUZZ_TARGET $cf 2>&1) | c++filt
    done
  done | tee $OUT_LOG_DIR/${BENCHMARK}-${test_fuzzer}.log | grep SUMMARY | sort | uniq
done

chmod 777 -R $OUT_LOG_DIR
