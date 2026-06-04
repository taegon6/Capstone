clear; clc;
scriptDir = fileparts(mfilename('fullpath'));
projectRoot = fullfile(scriptDir, '..', '..');
addpath(genpath(fullfile(projectRoot, 'matlab')));

dataDir = fullfile(projectRoot, 'data', 'public', 'homehar_subset');
files = dir(fullfile(dataDir, 'homehar_*_*.csv'));
assert(~isempty(files), 'No public HomeHAR subset files found. Run scripts/download_public_csi_subset.py first.');

fs = 150;
rows = struct([]);

figure('Name', 'Public HomeHAR CSI Subset', 'Color', 'w');
tiledlayout(numel(files), 2);
fig = gcf;

for i = 1:numel(files)
    filePath = fullfile(files(i).folder, files(i).name);
    label = extractBetween(string(files(i).name), "homehar_", "_");
    label = label(1);

    csi = loadCsiCsv(filePath);
    prep = preprocessCsi(csi);
    motion = detectMotion(prep.amplitudeZ, fs, windowSec=1.0, stepSec=0.5);
    [features, names] = extractCsiFeatures(prep.amplitudeZ, fs, windowSec=1.0, stepSec=0.5);

    diffIdx = strcmp(names, 'diff_energy');
    varIdx = strcmp(names, 'variance');
    domIdx = strcmp(names, 'dominant_frequency');

    rows(i).label = label;
    rows(i).file = string(filePath);
    rows(i).packets = size(csi, 1);
    rows(i).subcarriers = size(csi, 2);
    rows(i).mean_abs_z = mean(abs(prep.amplitudeZ), 'all');
    rows(i).mean_variance = mean(features(:, varIdx));
    rows(i).mean_diff_energy = mean(features(:, diffIdx));
    rows(i).median_dominant_frequency = median(features(:, domIdx));
    rows(i).moving_windows = nnz(motion.motion);
    rows(i).total_windows = numel(motion.motion);

    nexttile;
    imagesc(1:size(prep.amplitudeSmooth, 1), 1:size(prep.amplitudeSmooth, 2), prep.amplitudeSmooth.');
    axis xy;
    title(label + " heatmap");
    xlabel('Packet index');
    ylabel('Subcarrier');

    nexttile;
    plot(mean(prep.amplitudeZ, 2), 'LineWidth', 1.0);
    hold on;
    plot(abs([0; diff(mean(prep.amplitudeZ, 2))]), 'LineWidth', 0.8);
    title(label + " mean z / diff");
    xlabel('Packet index');
    grid on;
end

summaryTable = struct2table(rows);
disp(summaryTable(:, ["label", "packets", "subcarriers", "mean_abs_z", "mean_variance", "mean_diff_energy", "median_dominant_frequency", "moving_windows", "total_windows"]));

outDir = fullfile(projectRoot, 'data', 'results');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
writetable(summaryTable, fullfile(outDir, 'public_homehar_summary.csv'));
try
    exportgraphics(fig, fullfile(outDir, 'public_homehar_summary.png'), 'Resolution', 180);
catch
    saveas(fig, fullfile(outDir, 'public_homehar_summary.png'));
end
fprintf('Saved summary: %s\n', fullfile(outDir, 'public_homehar_summary.csv'));
fprintf('Saved figure: %s\n', fullfile(outDir, 'public_homehar_summary.png'));
