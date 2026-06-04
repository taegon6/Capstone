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
windowSec = 1.5;
stepSec = 0.5;
[featureTable, featureNames] = buildCsiFeatureDataset(filePaths, labels, fs, windowSec=windowSec, stepSec=stepSec);
model = trainCsiActivityModel(featureTable, featureNames, holdoutRatio=0.25, showChart=true);

% Use the most common parsed width from the training logs for live padding/cropping.
widths = zeros(numel(filePaths), 1);
for i = 1:numel(filePaths)
    csi = loadCsiCsv(char(filePaths(i)));
    widths(i) = size(csi, 2);
end
targetSubcarriers = mode(widths);

modelInfo = struct();
modelInfo.fs = fs;
modelInfo.windowSec = windowSec;
modelInfo.stepSec = stepSec;
modelInfo.featureNames = string(featureNames);
modelInfo.labels = featureTable.label;
modelInfo.filePaths = filePaths;
modelInfo.targetSubcarriers = targetSubcarriers;
modelInfo.trainedAt = string(datetime('now'));

outDir = fullfile(projectRoot, 'data', 'models');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
modelFile = fullfile(outDir, 'phone_motion_csi_model.mat');
save(modelFile, 'model', 'modelInfo');

outResults = fullfile(projectRoot, 'data', 'results');
if ~exist(outResults, 'dir')
    mkdir(outResults);
end
writetable(table(model.method, model.accuracy, height(featureTable), targetSubcarriers, ...
    'VariableNames', {'method','accuracy','numWindows','targetSubcarriers'}), ...
    fullfile(outResults, 'phone_realtime_model_summary.csv'));
try
    exportgraphics(gcf, fullfile(outResults, 'phone_realtime_model_confusion.png'), 'Resolution', 180);
catch
    saveas(gcf, fullfile(outResults, 'phone_realtime_model_confusion.png'));
end

fprintf('Saved realtime model: %s\n', modelFile);
fprintf('Accuracy: %.1f%% using %s\n', model.accuracy * 100, model.method);
fprintf('Target subcarriers for live monitor: %d\n', targetSubcarriers);

