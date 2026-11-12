#!/bin/bash

# usage: 2_run_sngl_btch.sh <batch script in ~/0_scripts/sngl_btch>
script=$1

# run from the project root: scripts resolve AAMNE_PROJECT_DIR (default ".") against it
cd ~/r_aamne_wwz

# years available in the raw CSV data
years=($(ls 0_data/oecd_aamne/aamne23 | grep -oE '[0-9]{4}\.csv$' | cut -c1-4 | sort -u))
n=${#years[@]}

# parallel batches: (RAM GB - 2) / 10 GB per year, at least 1
ram_gb=$(awk '/MemTotal/ {print int($2 / 1024 / 1024 + 0.999)}' /proc/meminfo)
slots=$(( (ram_gb - 2) / 10 )); (( slots < 1 )) && slots=1

# years per batch: spread evenly over the slots, capped at 3
size=$(( (n + slots - 1) / slots )); (( size > 3 )) && size=3

# one "<first year> <last year>" line per batch; xargs runs $slots at a time and queues the rest
echo "Starting $script: $n years, $slots at a time, $size years per batch"
for (( k = 0; k < n; k += size )); do
    batch=("${years[@]:k:size}")
    echo "${batch[0]} ${batch[${#batch[@]}-1]}"
done | nohup xargs -P "$slots" -L 1 sh -c \
    'sudo Rscript ~/0_scripts/sngl_btch/"$0" "$1" "$2" > ~/0_scripts/"${0%.R}_$1-$2_output.log" 2>&1' \
    "$script" > /dev/null 2>&1 &

echo "All batches have been queued in the background."
