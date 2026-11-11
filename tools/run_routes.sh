#!/bin/bash
# Grow coverage: run biased random input routes on a seedless NESRecomp interpreter host and merge the executed opcodes.
#   tools/run_routes.sh VERSION HOST_EXE SEEDBASE FRAMES COUNT     (HOST_EXE: nes_game.exe built WITHOUT cycle_seed_file)
# Writes work files under build/routes/<ver>/ and merges new opcodes into config/<ver>/coverage.json.
ver=$1; host=$2; base=$3; frames=$4; n=$5
root="$(cd "$(dirname "$0")/.." && pwd)"; w="$root/build/routes/$ver"; mkdir -p "$w"
for ((i=0;i<n;i++)); do s=$((base+i))
  python "$root/tools/mkroute.py" $s $frames "$w/r$s.txt" $((1500 + (s%9)*200))
  "$host" "$root/orig/excitebike_$ver.nes" --frames $frames --input "$w/r$s.txt" --miss-log "$w/m$s.txt" > "$w/run$s.txt" 2>&1 &
done; wait
python "$root/tools/miss2cov.py" --merge "$root/config/$ver/coverage.json" "$w"/m*.txt
