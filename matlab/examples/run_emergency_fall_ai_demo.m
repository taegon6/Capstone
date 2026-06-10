clear; clc;
% CSI-only 낙상 의심 이벤트 데모
% 실제 환자 데이터가 아니라 mock CSI로 normal / emergency_fall 분류 흐름만 확인한다.
scriptDir = fileparts(mfilename('fullpath'));
projectRoot = fullfile(scriptDir, '..', '..');
addpath(genpath(fullfile(projectRoot, 'matlab')));

fs = 50;
normalLabels = ["normal_static", "normal_walking", "normal_sitting", "normal_standing_up"];
classes = [normalLabels, "emergency_fall"];

X = [];
Y = strings(0, 1);
for i = 1:numel(classes)
    for rep = 1:40
        % class별 mock CSI window 생성
        amp = generateMockEmergencyCsiWindow(char(classes(i)), fs);
        prep = preprocessCsi(amp);
        [features, featureNames] = extractCsiFeatures(prep.amplitudeZ, fs, windowSec=2, stepSec=2);
        X = [X; features(1, :)]; %#ok<AGROW>
        if classes(i) == "emergency_fall"
            Y(end+1, 1) = "emergency_fall"; %#ok<AGROW>
        else
            Y(end+1, 1) = "normal"; %#ok<AGROW>
        end
    end
end

featureTable = array2table(X, 'VariableNames', matlab.lang.makeValidName(featureNames));
featureTable.label = categorical(Y);
% normal / emergency_fall 모델 학습
model = trainCsiActivityModel(featureTable, featureNames, holdoutRatio=0.3, showChart=true);

outDir = fullfile(projectRoot, 'data', 'results');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

summary = table();
summary.method = model.method;
summary.accuracy = model.accuracy;
summary.numWindows = height(featureTable);
summary.numClasses = numel(categories(featureTable.label));
summary.note = "Mock CSI only: fall emergency demo, not clinical validation";
disp(summary);

% 결과 저장
writetable(featureTable, fullfile(outDir, 'mock_emergency_fall_feature_dataset.csv'));
writetable(summary, fullfile(outDir, 'mock_emergency_fall_ai_summary.csv'));
try
    exportgraphics(gcf, fullfile(outDir, 'mock_emergency_fall_ai_confusion.png'), 'Resolution', 180);
catch
    saveas(gcf, fullfile(outDir, 'mock_emergency_fall_ai_confusion.png'));
end

fprintf('Saved emergency fall summary: %s\n', fullfile(outDir, 'mock_emergency_fall_ai_summary.csv'));
fprintf('Saved confusion figure: %s\n', fullfile(outDir, 'mock_emergency_fall_ai_confusion.png'));
