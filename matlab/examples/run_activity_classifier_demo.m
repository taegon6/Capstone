clear; clc;
addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..')));

model = trainActivityClassifier(showChart=true);
fprintf('Mock activity validation accuracy: %.1f%%\n', model.accuracy * 100);

data = generateMockCsiData(fs=50, durationSec=40);
prep = preprocessCsi(data.csi);
movingIdx = data.time >= 22 & data.time < 24;
[label, ~] = predictActivity(model, prep.amplitudeZ(movingIdx, :), data.fs);
fprintf('Example prediction for moving mock segment: %s\n', string(label));

