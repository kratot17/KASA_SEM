% Video Entropy Analysis (Spatial Information)
% This script calculates the average Shannon entropy of raw Y4M videos
% to quantify the scene complexity.

clear; clc; close all;

% Environment specific path convention
dir_raw = 'KASA/sem/raw_videos/';
dir_res = 'KASA/sem/results/';

sequences = {'crowd_run_1080p50.y4m', 'old_town_cross_1080p50.y4m', 'park_joy_1080p50.y4m'};

fprintf('Starting Entropy Analysis (this may take a moment for 1.5GB files)...\n');
fprintf('-------------------------------------------------------------------\n');

results = table();

for s = 1:length(sequences)
    filename = sequences{s};
    filepath = fullfile(dir_raw, filename);
    
    if ~isfile(filepath)
        fprintf('Warning: File %s not found. Skipping.\n', filename);
        continue;
    end
    
    % Open Y4M file
    fileID = fopen(filepath, 'r');
    
    % Read header (Y4M headers vary, but usually end with 0x0A)
    header = '';
    while true
        ch = fread(fileID, 1, 'char');
        if ch == 10 || isempty(ch), break; end
        header = [header, char(ch)];
    end
    
    % Extract dimensions from header (e.g., "YUV4MPEG2 W1920 H1080 ...")
    w_match = regexp(header, 'W(\d+)', 'tokens');
    h_match = regexp(header, 'H(\d+)', 'tokens');
    
    width = str2double(w_match{1}{1});
    height = str2double(h_match{1}{1});
    
    % Calculate frame sizes for YUV 4:2:0
    y_size = width * height;
    uv_size = (width/2) * (height/2);
    frame_size_bytes = y_size + 2 * uv_size;
    
    num_frames = 500; % We know our sequences have 500 frames
    frame_entropies = zeros(num_frames, 1);
    
    fprintf('Analyzing %s: ', filename);
    
    for f = 1:num_frames
        % Read Y plane only (luminance contains most structural info)
        y_data = fread(fileID, y_size, 'uint8');
        
        % Skip U and V planes
        fseek(fileID, 2 * uv_size, 'cof');
        
        if isempty(y_data), break; end
        
        % Calculate Shannon Entropy for this frame
        % entropy() is part of Image Processing Toolbox
        % If not available, we use a manual histogram-based calculation
        p = histcounts(y_data, 0:256, 'Normalization', 'probability');
        p = p(p > 0);
        frame_entropies(f) = -sum(p .* log2(p));
        
        if mod(f, 100) == 0, fprintf('.'); end
    end
    fclose(fileID);
    
    avg_entropy = mean(frame_entropies);
    max_entropy = max(frame_entropies);
    min_entropy = min(frame_entropies);
    std_entropy = std(frame_entropies);
    
    fprintf(' Done. Avg Entropy: %.4f\n', avg_entropy);
    
    % Add to results table
    newRow = table({filename}, avg_entropy, min_entropy, max_entropy, std_entropy, ...
        'VariableNames', {'Filename', 'Avg_Entropy', 'Min', 'Max', 'StdDev'});
    results = [results; newRow];
end

% Save results to CSV for LaTeX inclusion
writetable(results, fullfile(dir_res, 'video_entropy_results.csv'));
fprintf('-------------------------------------------------------------------\n');
fprintf('Analysis complete. Results saved to %s/video_entropy_results.csv\n', dir_res);
