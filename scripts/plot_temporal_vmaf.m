% Initialization of workspace
clear; clc; close all;

set(0, 'DefaultTextInterpreter', 'none');
set(0, 'DefaultLegendInterpreter', 'none');

dir_logs = 'KASA/sem/logs/';
dir_res = 'KASA/sem/latex/figures/';

sequences = {'crowd_run_1080p50', 'old_town_cross_1080p50', 'park_joy_1080p50'};
crf = '34';
vt_q = '66';

disp('Automatic export of temporal graphs in progress...');

for sIdx = 1:length(sequences)
    sequence = sequences{sIdx};
    
    files = {
        sprintf('%s_h264_cpu_crf%s.mp4_vmaf.csv', sequence, crf), 'libx264';
        sprintf('%s_h265_cpu_crf%s.mp4_vmaf.csv', sequence, crf), 'libx265';
        sprintf('%s_h265_hw_q%s.mp4_vmaf.csv', sequence, vt_q), 'hevc_videotoolbox';
        sprintf('%s_vp9_cpu_crf%s.webm_vmaf.csv', sequence, crf), 'libvpx-vp9';
        sprintf('%s_av1_cpu_crf%s.mp4_vmaf.csv', sequence, crf), 'libsvtav1'
    };

    fig = figure('Visible', 'off', 'Position', [100, 100, 900, 400]);
    hold on;
    grid on;

    for i = 1:size(files, 1)
        filepath = fullfile(dir_logs, files{i, 1});
        codecName = files{i, 2};

        if isfile(filepath)
            data = readtable(filepath);

            if any(strcmp(data.Properties.VariableNames, 'Frame')) && any(strcmp(data.Properties.VariableNames, 'vmaf'))
                plot(data.Frame, data.vmaf, '-', 'DisplayName', codecName, 'LineWidth', 1.2);
            end
        else
            fprintf('Warning: File %s not found.\n', files{i, 1});
        end
    end

    title(sprintf('Časový průběh VMAF: %s (CRF %s / Q %s)', sequence, crf, vt_q));
    xlabel('Snímek [-]');
    ylabel('VMAF Score [0-100]');
    legend('Location', 'southwest');
    ylim([0 100]);
    xlim([0 500]);

    pdfName = fullfile(dir_res, sprintf('per_frame_vmaf_%s.pdf', sequence));
    exportgraphics(fig, pdfName, 'ContentType', 'vector');
    close(fig);

    fprintf('Export complete. per_frame_vmaf_%s.pdf is saved in %s.\n', sequence, dir_res);
end