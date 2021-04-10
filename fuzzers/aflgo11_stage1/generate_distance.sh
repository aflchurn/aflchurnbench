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
cat $OUT/BBnames.txt | rev | cut -d: -f2- | rev | sort | uniq > $OUT/BBnames2.txt && mv $OUT/BBnames2.txt $OUT/BBnames.txt
cat $OUT/BBcalls.txt | sort | uniq > $OUT/BBcalls2.txt && mv $OUT/BBcalls2.txt $OUT/BBcalls.txt

/afl/scripts/gen_distance_fast.py /out/ /out/ $FUZZ_TARGET #target_binary /src/libgit2/
