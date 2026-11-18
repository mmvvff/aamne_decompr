#!/bin/bash

# usage: 2_run_sngl_btch.sh <batch script in ~/0_scripts/sngl_btch> [GB of RAM per year, default 7]
script=$1
gb_per_year=${2:-7}

# run from the project root: scripts resolve AAMNE_PROJECT_DIR (default ".") against it
cd ~/r_aamne_wwz

# data version: aamne23 (default), aamne26 or icio2026; set AAMNE_VERSION before running to override
export AAMNE_VERSION="${AAMNE_VERSION:-aamne23}"
[ "$AAMNE_VERSION" = "icio2026" ] && data_dir="oecd_icio/icio2026" || data_dir="oecd_aamne/$AAMNE_VERSION"
# yearly CSVs: flat under 0_data, or read in place from AAMNE_DATA_SOURCES (gmrio/, ICIO: gmrio/CurrentPrices/)
if [ "${AAMNE_DATA_FROM_SOURCES:-FALSE}" = "TRUE" ]; then
    data_dir="${AAMNE_DATA_SOURCES}${data_dir}/gmrio"; [ "$AAMNE_VERSION" = "icio2026" ] && data_dir="$data_dir/CurrentPrices"
else
    data_dir="0_data/$data_dir"
fi

# years available in the raw CSV data: AAMNE_ICIO<YYYY>.csv, <YYYY>_SML.csv, <YYYY>_PROJECTED.csv
years=($(ls "$data_dir" | grep -E '^(AAMNE_ICIO)?[0-9]{4}(_SML|_PROJECTED)?\.csv$' | grep -oE '[0-9]{4}' | sort -u))
n=${#years[@]}

# parallel batches: (RAM GB - 2) / GB per year, at least 1
ram_gb=$(awk '/MemTotal/ {print int($2 / 1024 / 1024 + 0.999)}' /proc/meminfo)
slots=$(( (ram_gb - 2) / gb_per_year )); (( slots < 1 )) && slots=1

# years per batch: spread evenly over the slots, capped at 3
size=$(( (n + slots - 1) / slots )); (( size > 3 )) && size=3

# one "<first year> <last year>" line per batch; xargs runs $slots at a time and queues the rest
echo "Starting $script: $n years, $slots at a time, $size years per batch"
for (( k = 0; k < n; k += size )); do
    batch=("${years[@]:k:size}")
    echo "${batch[0]} ${batch[${#batch[@]}-1]}"
done | nohup xargs -P "$slots" -L 1 sh -c \
    'sudo env $(env | grep "^AAMNE_") Rscript ~/0_scripts/sngl_btch/"$0" "$1" "$2" > ~/0_scripts/"${0%.R}_$1-$2_output.log" 2>&1' \
    "$script" > /dev/null 2>&1 &

echo "All batches have been queued in the background."
