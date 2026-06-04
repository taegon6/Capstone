clear; clc;
scriptDir = fileparts(mfilename('fullpath'));
projectRoot = fullfile(scriptDir, '..', '..');
addpath(genpath(fullfile(projectRoot, 'matlab')));

logDir = fullfile(projectRoot, 'data', 'csi_logs');
patterns = ["empty_phone", "static_person_phone", "moving_person_phone"];
labels = ["empty", "static_person", "moving_person"];
filePaths = strings(numel(patterns), 1);

for i = 1:numel(patterns)
    files = dir(fullfile(logDir, "*" + patterns(i) + "*.log"));
    assert(~isempty(files), 'No phone-connected log found for %s', patterns(i));
    [~, newestIdx] = max([files.datenum]);
    filePaths(i) = fullfile(files(newestIdx).folder, files(newestIdx).name);
end

fs = 50;
[featureTable, featureNames] = buildCsiFeatureDataset(filePaths, labels, fs, windowSec=1.5, stepSec=0.5);
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

writetable(featureTable, fullfile(outDir, 'phone_motion_feature_dataset.csv'));
writetable(summary, fullfile(outDir, 'phone_motion_ai_summary.csv'));
try
    exportgraphics(gcf, fullfile(outDir, 'phone_motion_ai_confusion.png'), 'Resolution', 180);
catch
    saveas(gcf, fullfile(outDir, 'phone_motion_ai_confusion.png'));
end

fprintf('Saved feature dataset: %s\n', fullfile(outDir, 'phone_motion_feature_dataset.csv'));
fprintf('Saved AI summary: %s\n', fullfile(outDir, 'phone_motion_ai_summary.csv'));
fprintf('Saved confusion figure: %s\n', fullfile(outDir, 'phone_motion_ai_confusion.png'));

