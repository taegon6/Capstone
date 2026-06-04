clc;
scriptDir = fileparts(mfilename('fullpath'));
projectRoot = fullfile(scriptDir, '..', '..');
addpath(genpath(fullfile(projectRoot, 'matlab')));

if exist('logFile', 'var') == 0
    logDir = fullfile(projectRoot, 'data', 'csi_logs');
    files = dir(fullfile(logDir, '*.log'));
    assert(~isempty(files), 'No CSI log files found in data/csi_logs.');
    [~, newestIdx] = max([files.datenum]);
    logFile = fullfile(files(newestIdx).folder, files(newestIdx).name);
end

fprintf('Loading CSI log: %s\n', logFile);
csi = loadCsiCsv(logFile);
assert(~isempty(csi), 'No CSI rows parsed from log.');

fs = 50;
prep = preprocessCsi(csi);
motion = detectMotion(prep.amplitudeZ, fs, windowSec=1.5, stepSec=0.5);

figure('Name', 'Real ESP32 CSI Log Demo', 'Color', 'w');
tiledlayout(3, 1);
fig = gcf;

nexttile;
imagesc(1:size(prep.amplitudeSmooth, 1), 1:size(prep.amplitudeSmooth, 2), prep.amplitudeSmooth.');
axis xy;
xlabel('Packet index');
ylabel('Subcarrier');
title('Real ESP32 CSI amplitude heatmap');
colorbar;

nexttile;
plot(mean(prep.amplitudeZ, 2), 'LineWidth', 1.2);
xlabel('Packet index');
ylabel('Mean amplitude z-score');
title('Preprocessed CSI amplitude');
grid on;

nexttile;
stairs(motion.time, motion.motion, 'LineWidth', 1.5);
hold on;
plot(motion.time, motion.score ./ max(motion.score + eps), 'LineWidth', 1.0);
xlabel('Estimated time (s)');
ylabel('Motion');
title(sprintf('Motion windows: %d / %d moving', nnz(motion.motion), numel(motion.motion)));
ylim([-0.1 1.2]);
grid on;

fprintf('Parsed CSI matrix size: %d packets x %d subcarriers\n', size(csi, 1), size(csi, 2));
fprintf('Motion windows: %d / %d moving\n', nnz(motion.motion), numel(motion.motion));

outDir = fullfile(projectRoot, 'data', 'results');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
try
    exportgraphics(fig, fullfile(outDir, 'real_csi_log_demo.png'), 'Resolution', 180);
catch
    saveas(fig, fullfile(outDir, 'real_csi_log_demo.png'));
end
fprintf('Saved figure: %s\n', fullfile(outDir, 'real_csi_log_demo.png'));
