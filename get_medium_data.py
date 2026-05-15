import csv

video = 'crowd_run_1080p50'
ORIGINAL_BYTES = 1555203036

enc_data = {}
with open('results/encoding_results.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        if row['File'] == video and row['CRF'] in ['34', '66']:
            codec = row['Codec']
            enc_data[codec] = {
                'time': int(row['Time_Seconds']),
                'size': int(row['Size_Bytes']) / 1000000
            }

vmaf_data = {}
with open('results/metrics_results_vmaf.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        vid_file = row['Encoded_File']
        if video in vid_file and ('crf34' in vid_file or 'q66' in vid_file):
            if 'h264' in vid_file: codec = 'libx264'
            elif 'h265_hw' in vid_file: codec = 'hevc_videotoolbox'
            elif 'h265_cpu' in vid_file: codec = 'libx265'
            elif 'vp9' in vid_file: codec = 'libvpx-vp9'
            elif 'av1' in vid_file: codec = 'libsvtav1'
            vmaf_data[codec] = float(row['VMAF_Score'])

print("Data for Table:")
for codec in ['hevc_videotoolbox', 'libx264', 'libx265', 'libsvtav1', 'libvpx-vp9']:
    if codec in enc_data and codec in vmaf_data:
        fps = 500 / enc_data[codec]['time']
        print(f"{codec}: FPS={fps:.2f}, Time={enc_data[codec]['time']}s, CompMB={enc_data[codec]['size']:.2f}, VMAF={vmaf_data[codec]:.2f}")
