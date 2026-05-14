clear; clc;
addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..')));

data = generateMockCsiData(fs=50, durationSec=40, numSubcarriers=52);
prep = preprocessCsi(data.csi);

baselineIdx = find(data.time < 10);
currentIdx = find(data.time >= 10);
presence = detectPresence(prep.amplitudeSmooth, baselineIdx, currentIdx, autoThreshold=true);
motion = detectMotion(prep.amplitudeZ, data.fs, windowSec=1.5, stepSec=0.5);

fprintf('Presence: %d, score %.3f, threshold %.3f\n', presence.presence, presence.score, presence.threshold);
fprintf('Motion windows: %d / %d moving\n', nnz(motion.motion), numel(motion.motion));

plotCsiDashboard(data, prep, presence, motion);
