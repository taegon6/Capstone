clear; clc;
addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..')));

data = generateMockCsiData(fs=50, durationSec=45, respirationHz=0.25);
prep = preprocessCsi(data.csi);
idx = data.time >= 32;
signal = prep.amplitudeSmooth(idx, :);

result = estimateRespirationBPM(signal, data.fs);
fprintf('Respiration estimate: %.1f BPM, status=%s\n', result.bpm, result.status);

figure('Name', 'Respiration Demo', 'Color', 'w');
tiledlayout(3, 1);

nexttile;
plot(data.time(idx), mean(signal, 2));
xlabel('Time (s)');
ylabel('Amplitude');
title('Mock static CSI breathing segment');
grid on;

nexttile;
plot(data.time(idx), result.filteredSignal);
xlabel('Time (s)');
ylabel('Filtered');
title('0.1-0.5 Hz band filtered signal');
grid on;

nexttile;
plot(result.frequencyHz, result.spectrum);
xlabel('Frequency (Hz)');
ylabel('Power');
title(sprintf('Dominant %.3f Hz = %.1f BPM', result.peakFrequencyHz, result.bpm));
grid on;

