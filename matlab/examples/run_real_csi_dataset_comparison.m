clear; clc;
scriptDir = fileparts(mfilename('fullpath'));
projectRoot = fullfile(scriptDir, '..', '..');
addpath(genpath(fullfile(projectRoot, 'matlab')));

logDir = fullfile(projectRoot, 'data', 'csi_logs');
labels = ["empty", "static_person", "moving_person"];
fs = 50;

rows = struct([]);

figure('Name', 'Real CSI Dataset Comparison', 'Color', 'w');
tiledlayout(numel(labels), 2);
fig = gcf;

for i = 1:numel(labels)
    files = dir(fullfile(logDir, "*" + labels(i) + "*.log"));
    assert(~isempty(files), 'No log found for label %s', labels(i));
    [~, newestIdx] = max([files.datenum]);
    logFile = fullfile(files(newestIdx).folder, files(newestIdx).name);

    csi = loadCsiCsv(logFile);
    prep = preprocessCsi(csi);
    motion = detectMotion(prep.amplitudeZ, fs, windowSec=1.5, stepSec=0.5);
    [features, names] = extractCsiFeatures(prep.amplitudeZ, fs, windowSec=1.5, stepSec=1.5);

    diffIdx = strcmp(names, 'diff_energy');
    varIdx = strcmp(names, 'variance');
    energyIdx = strcmp(names, 'energy');

    rows(i).label = labels(i);
    rows(i).file = string(logFile);
    rows(i).packets = size(csi, 1);
    rows(i).subcarriers = size(csi, 2);
    rows(i).mean_abs_z = mean(abs(prep.amplitudeZ), 'all');
    rows(i).mean_variance = mean(features(:, varIdx));
    rows(i).mean_energy = mean(features(:, energyIdx));
    rows(i).mean_diff_energy = mean(features(:, diffIdx));
    rows(i).moving_windows = nnz(motion.motion);
    rows(i).total_windows = numel(motion.motion);

    nexttile;
    imagesc(1:size(prep.amplitudeSmooth, 1), 1:size(prep.amplitudeSmooth, 2), prep.amplitudeSmooth.');
    axis xy;
    title(labels(i) + " heatmap");
    xlabel('Packet index');
    ylabel('Subcarrier');

    nexttile;
    plot(mean(prep.amplitudeZ, 2), 'LineWidth', 1.1);
    hold on;
    plot(abs([0; diff(mean(prep.amplitudeZ, 2))]), 'LineWidth', 0.9);
    title(labels(i) + " mean z / diff");
    xlabel('Packet index');
    grid on;
end

summaryTable = struct2table(rows);
disp(summaryTable(:, ["label", "packets", "subcarriers", "mean_abs_z", "mean_variance", "mean_energy", "mean_diff_energy", "moving_windows", "total_windows"]));

outDir = fullfile(projectRoot, 'data', 'results');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
writetable(summaryTable, fullfile(outDir, 'real_csi_dataset_summary.csv'));
try
    exportgraphics(fig, fullfile(outDir, 'real_csi_dataset_comparison.png'), 'Resolution', 180);
catch
    saveas(fig, fullfile(outDir, 'real_csi_dataset_comparison.png'));
end
fprintf('Saved summary: %s\n', fullfile(outDir, 'real_csi_dataset_summary.csv'));
fprintf('Saved figure: %s\n', fullfile(outDir, 'real_csi_dataset_comparison.png'));
