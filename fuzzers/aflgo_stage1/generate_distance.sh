#!/bin/bash
cat $OUT/BBnames.txt | rev | cut -d: -f2- | rev | sort | uniq > $OUT/BBnames2.txt && mv $OUT/BBnames2.txt $OUT/BBnames.txt
cat $OUT/BBcalls.txt | sort | uniq > $OUT/BBcalls2.txt && mv $OUT/BBcalls2.txt $OUT/BBcalls.txt

/afl/scripts/genDistance.sh /out/ /out/  #target_binary
