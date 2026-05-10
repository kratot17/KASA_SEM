#!/bin/bash

DIR_RAW="raw_videos"
DIR_ENC="encoded_videos"
DIR_RES="results"
INPUT_FILES=("crowd_run_1080p50.y4m" "old_town_cross_1080p50.y4m" "park_joy_1080p50.y4m")
CRF_VALUES=(22 28 34 40)
LOG_FILE="$DIR_RES/encoding_results.csv"

# Pre-flight check. Erasing old log and writing CSV header.
echo "File,Codec,CRF,Time_Seconds,Size_Bytes" > "$LOG_FILE"

# Batch encoding process started.
for input_video_name in "${INPUT_FILES[@]}"; do
    input_video="$DIR_RAW/$input_video_name"
    
    # Verifying file existence.
    if [ ! -f "$input_video" ]; then
        echo "Warning: File $input_video not found, skipping."
        continue
    fi

    # Extracting base name for output files.
    base_name=$(basename "$input_video_name" .y4m)
    
    for crf in "${CRF_VALUES[@]}"; do
        
        # ---------------------------------------------------------
        # 1. H.264 (AVC) - CPU
        # ---------------------------------------------------------
        echo "Processing $base_name | H.264 CPU | CRF $crf"
        output_file="$DIR_ENC/${base_name}_h264_cpu_crf${crf}.mp4"
        start_time=$(date +%s)
        
        ffmpeg -y -i "$input_video" -c:v libx264 -preset medium -crf "$crf" "$output_file" 2>/dev/null
        
        end_time=$(date +%s)
        time_diff=$((end_time - start_time))
        file_size=$(stat -f%z "$output_file")
        echo "${base_name},libx264,${crf},${time_diff},${file_size}" >> "$LOG_FILE"

        # ---------------------------------------------------------
        # 2. H.265 (HEVC) - CPU
        # ---------------------------------------------------------
        echo "Processing $base_name | H.265 CPU | CRF $crf"
        output_file="$DIR_ENC/${base_name}_h265_cpu_crf${crf}.mp4"
        start_time=$(date +%s)
        
        ffmpeg -y -i "$input_video" -c:v libx265 -preset medium -crf "$crf" "$output_file" 2>/dev/null
        
        end_time=$(date +%s)
        time_diff=$((end_time - start_time))
        file_size=$(stat -f%z "$output_file")
        echo "${base_name},libx265,${crf},${time_diff},${file_size}" >> "$LOG_FILE"

        # ---------------------------------------------------------
        # 3. H.265 (HEVC) - Apple Hardware Acceleration (VideoToolbox)
        # ---------------------------------------------------------
        # Note: VideoToolbox uses -q:v instead of -crf for quality scaling
        # Mapping standard CRF approximation to VideoToolbox quality (around 40-70 range)
        vt_q=$((100 - crf)) 
        
        echo "Processing $base_name | H.265 HW (M1) | Q $vt_q"
        output_file="$DIR_ENC/${base_name}_h265_hw_q${vt_q}.mp4"
        start_time=$(date +%s)
        
        ffmpeg -y -i "$input_video" -c:v hevc_videotoolbox -q:v "$vt_q" "$output_file" 2>/dev/null
        
        end_time=$(date +%s)
        time_diff=$((end_time - start_time))
        file_size=$(stat -f%z "$output_file")
        echo "${base_name},hevc_videotoolbox,${vt_q},${time_diff},${file_size}" >> "$LOG_FILE"

        # ---------------------------------------------------------
        # 4. VP9 - CPU
        # ---------------------------------------------------------
        echo "Processing $base_name | VP9 CPU | CRF $crf"
        output_file="$DIR_ENC/${base_name}_vp9_cpu_crf${crf}.webm"
        start_time=$(date +%s)
        
        ffmpeg -y -i "$input_video" -c:v libvpx-vp9 -b:v 0 -crf "$crf" -cpu-used 2 "$output_file" 2>/dev/null
        
        end_time=$(date +%s)
        time_diff=$((end_time - start_time))
        file_size=$(stat -f%z "$output_file")
        echo "${base_name},libvpx-vp9,${crf},${time_diff},${file_size}" >> "$LOG_FILE"

        # ---------------------------------------------------------
        # 5. AV1 - CPU (libsvtav1)
        # ---------------------------------------------------------
        echo "Processing $base_name | AV1 CPU | CRF $crf"
        output_file="$DIR_ENC/${base_name}_av1_cpu_crf${crf}.mp4"
        start_time=$(date +%s)
        
        ffmpeg -y -i "$input_video" -c:v libsvtav1 -preset 6 -crf "$crf" "$output_file" 2>/dev/null
        
        end_time=$(date +%s)
        time_diff=$((end_time - start_time))
        file_size=$(stat -f%z "$output_file")
        echo "${base_name},libsvtav1,${crf},${time_diff},${file_size}" >> "$LOG_FILE"

    done
done

# Job done. All generated statistics saved to encoding_results.csv.
echo "Encoding test finished. Check $LOG_FILE for execution times and file sizes."