function [featureTable, featureNames] = buildCsiFeatureDataset(filePaths, labels, fs, opts)
%BUILDCSIFEATUREDATASET Build a window-level CSI feature table from log files.
arguments
    filePaths
    labels
    fs (1,1) double = 50
    opts.windowSec (1,1) double = 1.0
    opts.stepSec (1,1) double = 0.5
end

filePaths = string(filePaths);
labels = string(labels);
assert(numel(filePaths) == numel(labels), 'filePaths and labels must have the same length.');

allFeatures = [];
allLabels = strings(0, 1);
allFiles = strings(0, 1);
allTimes = [];
featureNames = {};

for i = 1:numel(filePaths)
    csi = loadCsiCsv(char(filePaths(i)));
    if isempty(csi)
        warning('No CSI rows parsed from %s', filePaths(i));
        continue;
    end
    prep = preprocessCsi(csi);
    [features, names, times] = extractCsiFeatures( ...
        prep.amplitudeZ, fs, windowSec=opts.windowSec, stepSec=opts.stepSec);
    featureNames = names;
    allFeatures = [allFeatures; features]; %#ok<AGROW>
    allLabels = [allLabels; repmat(labels(i), size(features, 1), 1)]; %#ok<AGROW>
    allFiles = [allFiles; repmat(filePaths(i), size(features, 1), 1)]; %#ok<AGROW>
    allTimes = [allTimes; times]; %#ok<AGROW>
end

featureTable = array2table(allFeatures, 'VariableNames', matlab.lang.makeValidName(featureNames));
featureTable.label = categorical(allLabels);
featureTable.sourceFile = allFiles;
featureTable.windowTime = allTimes;
end

