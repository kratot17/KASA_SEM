% Initialization of workspace and data import
clear; clc; close all;

% Load raw CSV files
set(0, 'DefaultTextInterpreter', 'none');
set(0, 'DefaultLegendInterpreter', 'none');

dir_res = 'KASA/sem/results/';
dir_latex = 'KASA/sem/latex/figures/';
encData = readtable(fullfile(dir_res, 'encoding_results.csv'));
metData = readtable(fullfile(dir_res, 'metrics_results_vmaf.csv'));

% Pre-allocation of arrays for merging logic
numRows = height(metData);
File = strings(numRows, 1);
Codec = strings(numRows, 1);
CRF = zeros(numRows, 1);

% Parsing filenames to extract properties for join operation
for i = 1:numRows
    filename = metData.Encoded_File{i};
    
    % Extract base filename
    baseName = regexprep(filename, '_(h264|h265|vp9|av1).*', '');
    File(i) = string(baseName);
    
    % Map filename to exact codec name from encoding_results
    if contains(filename, 'h264')
        Codec(i) = "libx264";
    elseif contains(filename, 'h265_cpu')
        Codec(i) = "libx265";
    elseif contains(filename, 'h265_hw')
        Codec(i) = "hevc_videotoolbox";
    elseif contains(filename, 'vp9')
        Codec(i) = "libvpx-vp9";
    elseif contains(filename, 'av1')
        Codec(i) = "libsvtav1";
    end
    
    % Extract CRF or VT quality parameter
    tokens = regexp(filename, '(crf|q)(\d+)', 'tokens');
    if ~isempty(tokens)
        CRF(i) = str2double(tokens{1}{2});
    end
end

% Append extracted properties to the metrics table
metData.File = File;
metData.Codec = Codec;
metData.CRF = CRF;

% Standardize data types for innerjoin
encData.File = string(encData.File);
encData.Codec = string(encData.Codec);

% Merge tables
joinedData = innerjoin(encData, metData, 'Keys', {'File', 'Codec', 'CRF'});

% Convert file size to MB for readability
joinedData.Size_MB = joinedData.Size_Bytes / (1024 * 1024);

% Setup visualization parameters
uniqueFiles = unique(joinedData.File);
uniqueCodecs = unique(joinedData.Codec);
metrics = ["PSNR_Avg", "SSIM_Avg", "VMAF_Score"];
metricLabels = ["PSNR [dB]", "SSIM [-]", "VMAF Score [0-100]"];

disp('Automatic export of graphs in progress...');

% Iterate over every source video sequence
for fIdx = 1:length(uniqueFiles)
    currentFile = uniqueFiles(fIdx);
    fileData = joinedData(joinedData.File == currentFile, :);
    
    % Iterate over every measured metric
    for mIdx = 1:length(metrics)
        currentMetric = metrics(mIdx);
        
        fig = figure('Visible', 'off');
        hold on;
        grid on;
        
        % Plot curve for each codec
        for cIdx = 1:length(uniqueCodecs)
            currentCodec = uniqueCodecs(cIdx);
            codecData = fileData(fileData.Codec == currentCodec, :);
            
            if ~isempty(codecData)
                % Ensure correct drawing order from smallest to largest file
                codecData = sortrows(codecData, 'Size_MB');
                plot(codecData.Size_MB, codecData.(currentMetric), '-o', ...
                    'DisplayName', currentCodec, 'LineWidth', 1.5);
            end
        end
        
        % Typography and axis formatting
        cleanMetric = strrep(currentMetric, '_Avg', '');
        
        title(sprintf('R-D Krivka (%s): %s', cleanMetric, currentFile));
        xlabel('Velikost souboru [MB]');
        ylabel(metricLabels(mIdx));
        legend('Location', 'best');
        
        % Construct destination filename
        if currentMetric == "VMAF_Score"
            pdfName = fullfile(dir_latex, sprintf('rd_vmaf_%s.pdf', currentFile));
        else
            pdfName = fullfile(dir_latex, sprintf('rd_%s_%s.pdf', lower(extractBefore(currentMetric, '_')), currentFile));
        end
        
        % Export complete. rd_psnr.pdf through rd_vmaf.pdf are saved
        exportgraphics(fig, pdfName, 'ContentType', 'vector');
        close(fig);
    end
end

disp('Done. All PDF files successfully generated.');