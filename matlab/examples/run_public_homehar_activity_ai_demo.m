clear; clc;
scriptDir = fileparts(mfilename('fullpath'));
projectRoot = fullfile(scriptDir, '..', '..');
addpath(genpath(fullfile(projectRoot, 'matlab')));

dataDir = fullfile(projectRoot, 'data', 'public', 'homehar_subset');
files = dir(fullfile(dataDir, 'homehar_*_*.csv'));
assert(~isempty(files), 'No HomeHAR subset files found. Run scripts/download_public_csi_subset.py first.');

filePaths = strings(numel(files), 1);
labels = strings(numel(files), 1);
for i = 1:numel(files)
    filePaths(i) = fullfile(files(i).folder, files(i).name);
    token = regexp(files(i).name, 'homehar_(.+?)_\d+rows\.csv', 'tokens', 'once');
    labels(i) = string(token{1});
end

fs = 150;
[featureTable, featureNames] = buildCsiFeatureDataset(filePaths, labels, fs, windowSec=0.5, stepSec=0.25);
model = trainCsiActivityModel(featureTable, featureNames, holdoutRatio=0.35, showChart=true);

outDir = fullfile(projectRoot, 'data', 'results');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

summary = table();
summary.method = model.method;
summary.accuracy = model.accuracy;
summary.numWindows = height(featureTable);
summary.numClasses = numel(categories(featureTable.label));
disp(summary);

writetable(featureTable, fullfile(outDir, 'public_homehar_feature_dataset.csv'));
writetable(summary, fullfile(outDir, 'public_homehar_activity_ai_summary.csv'));
try
    exportgraphics(gcf, fullfile(outDir, 'public_homehar_activity_ai_confusion.png'), 'Resolution', 180);
catch
    saveas(gcf, fullfile(outDir, 'public_homehar_activity_ai_confusion.png'));
end

fprintf('Saved feature dataset: %s\n', fullfile(outDir, 'public_homehar_feature_dataset.csv'));
fprintf('Saved AI summary: %s\n', fullfile(outDir, 'public_homehar_activity_ai_summary.csv'));
fprintf('Saved confusion figure: %s\n', fullfile(outDir, 'public_homehar_activity_ai_confusion.png'));

