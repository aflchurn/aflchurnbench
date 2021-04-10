#!/bin/bash
# Copyright 2020 Google LLC
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

# Use this script to run a new aflchurnbench experiment.

bash_script_dir=$(realpath $(dirname $0))
aflchurnbench_root="$(dirname "$bash_script_dir")"

# Make sure submodules use ssh protocol
sed -i .bak 's!https://github.com/!git@github.com:!g' .gitmodules

git pull --rebase
git submodule update --init
git submodule update --remote --merge

# make install-dependencies
# source .venv/bin/activate

# These paths are specific to the user's machine.
experiment_working_dir=$HOME/aflchurnbench-workdir
config_filename="aflchurnbench-experiment-config.yaml"
cd $experiment_working_dir

# not qualified: libheif_encoder-fuzzer libheif_file-fuzzer keystone_fuzz_asm_arm_armv8be keystone_fuzz_asm_mips keystone_fuzz_asm_systemz keystone_fuzz_asm_ppc64be libcbor_cbor_load_fuzzer
# quick crash: jsoncpp_jsoncpp_fuzzer libsass_data_context_fuzzer 
# never crash: htslib_hts_open_fuzzer libgit2_patch_parse_fuzzer muparser_set_eval_fuzzer ndpi_fuzz_ndpi_reader oniguruma_fuzzer 
# long hour building: openssl_client
# build error: serenity_fuzzbmploader serenity_fuzzshell
# aflgo error: aspell_aspell_fuzzer file_magic_fuzzer yara_dotnet_fuzzer libxml2_libxml2_xml_reader_for_file_fuzzer readstat_fuzz_format_spss_commands unicorn_fuzz_emu_arm_armbe grok_grk_decompress_fuzzer ndpi_fuzz_process_packet
# non-regression: harfbuzz_hb-shape-fuzzer
benchmarks="unbound_fuzz_1_fuzzer usrsctp_fuzzer_connect systemd_fuzz-varlink openvswitch_odp_target neomutt_address-fuzz picotls_fuzz-asn1 openssl_x509 libgit2_objects_fuzzer libhtp_fuzz_htp zstd_stream_decompress"

# afl aflchurn aflchurn_aco aflchurn_noage aflchurn_nochurn aflchurn_seedalias aflchurn_seedalias_aco
fuzzers="aflgo aflchurn"

experiment_name=$(date --iso-8601)-"aflchurnbench-aflgo"

run_experiment=$aflchurnbench_root/experiment/run_experiment.py
export PYTHONPATH=$aflchurnbench_root
python $run_experiment --benchmarks $benchmarks --fuzzers $fuzzers --experiment-name $experiment_name --experiment-config $config_filename
