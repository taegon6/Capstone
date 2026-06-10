clear; clc; close all;
% Wi-Fi CSI 기반 비접촉 환자 이상 이벤트 감지 데모
% 실제 ESP32 로그가 있으면 사용하고, 없으면 mock 데이터로 실행된다.

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'matlab_simple')));

fs = 50;  % CSI packet rate는 데모용으로 50 Hz로 가정
data = load_or_mock_csi(projectRoot);

allFeatures = table();
debugData = struct();
for i = 1:numel(data)
    [T, featureNames, debug] = extract_simple_csi_features(data(i).csi, data(i).label, fs);
    allFeatures = [allFeatures; T]; %#ok<AGROW>
    debugData(i).label = data(i).label; %#ok<SAGROW>
    debugData(i).debug = debug;
end

% 발표 목적은 낙상 "진단"이 아니라 후보 감지라서 normal/fall_candidate 두 class로 묶었다.
allFeatures.aiLabel = repmat("normal", height(allFeatures), 1);
allFeatures.aiLabel(allFeatures.label == "fall_candidate") = "fall_candidate";
allFeatures.aiLabel = categorical(allFeatures.aiLabel);

X = table2array(allFeatures(:, featureNames));
Y = allFeatures.aiLabel;

% 간단한 머신러닝 모델. 복잡한 딥러닝 대신 decision tree를 사용했다.
rng(7);
cv = cvpartition(Y, 'HoldOut', 0.3);
XTrain = X(training(cv), :);
YTrain = Y(training(cv));
XTest = X(test(cv), :);
YTest = Y(test(cv));

model = fitctree(XTrain, YTrain);
YPred = predict(model, XTest);
accuracy = mean(YPred == YTest);

fprintf('\n=== CSI Capstone Simple Demo ===\n');
fprintf('Total windows: %d\n', height(allFeatures));
fprintf('AI model: decision tree\n');
fprintf('Test accuracy: %.1f %%\n', accuracy * 100);
fprintf('Note: fall_candidate is mock data, not medical diagnosis.\n\n');

figure('Name', 'CSI Capstone Simple Demo', 'Color', 'w', 'Position', [100 100 1200 720]);
tiledlayout(2, 2, 'TileSpacing', 'compact');

nexttile;
imagesc(debugData(3).debug.amplitudeZ.');
axis xy;
title('Moving person CSI amplitude');
xlabel('Packet');
ylabel('Subcarrier');
colorbar;

nexttile;
displayAiLabel = categorical(replace(string(allFeatures.aiLabel), "_", " "));
gscatter(allFeatures.variance, allFeatures.diff_energy, displayAiLabel);
grid on;
xlabel('Variance');
ylabel('Diff energy');
title('Feature space');

nexttile;
try
    yTestDisp = categorical(replace(string(YTest), "_", " "));
    yPredDisp = categorical(replace(string(YPred), "_", " "));
    confusionchart(yTestDisp, yPredDisp);
    title(sprintf('AI result, accuracy %.1f%%', accuracy * 100));
catch
    cm = confusionmat(YTest, YPred);
    imagesc(cm);
    axis equal tight;
    title(sprintf('AI result, accuracy %.1f%%', accuracy * 100));
    colorbar;
end

nexttile;
labels = unique(allFeatures.label, 'stable');
meanDiff = zeros(numel(labels), 1);
for i = 1:numel(labels)
    meanDiff(i) = mean(allFeatures.diff_energy(allFeatures.label == labels(i)));
end
displayLabels = replace(labels, "_", " ");
bar(categorical(displayLabels, displayLabels, 'Ordinal', true), meanDiff);
title('Mean diff energy by label');
ylabel('Diff energy');
grid on;

outDir = fullfile(projectRoot, 'deliverables', 'simple_results');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
writetable(allFeatures, fullfile(outDir, 'simple_csi_features.csv'));
exportgraphics(gcf, fullfile(outDir, 'simple_csi_demo_result.png'), 'Resolution', 180);

fprintf('Saved result figure: %s\n', fullfile(outDir, 'simple_csi_demo_result.png'));
