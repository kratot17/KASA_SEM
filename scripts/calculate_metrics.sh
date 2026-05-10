#!/bin/bash

DIR_RAW="raw_videos"
DIR_ENC="encoded_videos"
DIR_LOGS="logs"
DIR_RES="results"

LOG_FILE="$DIR_RES/metrics_results_vmaf.csv"

echo "Encoded_File,Reference_File,PSNR_Avg,SSIM_Avg,VMAF_Score" > "$LOG_FILE"

for encoded_path in "$DIR_ENC"/*.{mp4,webm}; do
    
    [ -e "$encoded_path" ] || continue

    encoded_vid=$(basename "$encoded_path")
    base_name=$(echo "$encoded_vid" | sed -E 's/_(h264|h265|vp9|av1).*//')
    
    ref_vid="${base_name}.y4m"
    ref_path="$DIR_RAW/$ref_vid"

    if [ ! -f "$ref_path" ]; then
        echo "Reference video $ref_path not found for $encoded_vid. Skipping."
        continue
    fi

    echo "Calculating metrics for: $encoded_vid"

    # FFmpeg s přesměrováním do příslušné složky per-frame logů
    output=$(ffmpeg -i "$encoded_path" -i "$ref_path" \
        -lavfi "[0:v][1:v]psnr=stats_file=$DIR_LOGS/${encoded_vid}_psnr.log;[0:v][1:v]ssim=stats_file=$DIR_LOGS/${encoded_vid}_ssim.log;[0:v][1:v]libvmaf=n_threads=8:log_path=$DIR_LOGS/${encoded_vid}_vmaf.csv:log_fmt=csv" \
        -f null - 2>&1)

    psnr_val=$(echo "$output" | grep "Parsed_psnr" | grep -Eo "average:[0-9.]+" | cut -d':' -f2 | tail -n 1)
    ssim_val=$(echo "$output" | grep "Parsed_ssim" | grep -Eo "All:[0-9.]+" | cut -d':' -f2 | tail -n 1)
    vmaf_val=$(echo "$output" | grep -Eo "VMAF score: [0-9.]+" | grep -Eo "[0-9.]+")

    psnr_val=${psnr_val:-N/A}
    ssim_val=${ssim_val:-N/A}
    vmaf_val=${vmaf_val:-N/A}

    echo "${encoded_vid},${ref_vid},${psnr_val},${ssim_val},${vmaf_val}" >> "$LOG_FILE"
    echo " -> PSNR: $psnr_val | SSIM: $ssim_val | VMAF: $vmaf_val"

done

echo "Metrics calculation complete. Results saved to $LOG_FILE."