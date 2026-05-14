function data = generateMockCsiData(opts)
%GENERATEMOCKCSIDATA Create mock CSI with empty/static/motion/respiration parts.
arguments
    opts.fs (1,1) double = 50
    opts.durationSec (1,1) double = 40
    opts.numSubcarriers (1,1) double = 52
    opts.respirationHz (1,1) double = 0.25
end

fs = opts.fs;
t = (0:1/fs:opts.durationSec-1/fs).';
n = numel(t);
sc = 1:opts.numSubcarriers;
baseAmp = 20 + 2 * sin(sc / 7);
amp = repmat(baseAmp, n, 1) + randn(n, opts.numSubcarriers) * 0.4;
phase = randn(n, opts.numSubcarriers) * 0.05;
labels = strings(n, 1);

seg1 = t < 10;
seg2 = t >= 10 & t < 22;
seg3 = t >= 22 & t < 32;
seg4 = t >= 32;
labels(seg1) = "empty";
labels(seg2) = "static_person";
labels(seg3) = "moving_person";
labels(seg4) = "breathing_static";

personShape = 2.0 * exp(-((sc - 26).^2) / 180);
amp(seg2 | seg3 | seg4, :) = amp(seg2 | seg3 | seg4, :) + personShape;
motion = 2.5 * sin(2*pi*1.2*t(seg3)) + 1.4 * randn(nnz(seg3), 1);
amp(seg3, :) = amp(seg3, :) + motion .* sin(sc / 4);
resp = 0.8 * sin(2*pi*opts.respirationHz*t(seg4));
amp(seg4, :) = amp(seg4, :) + resp .* exp(-((sc - 18).^2) / 130);

csi = amp .* exp(1i * phase);
raw = zeros(n, opts.numSubcarriers * 2);
raw(:, 1:2:end) = imag(csi);
raw(:, 2:2:end) = real(csi);

data = struct();
data.fs = fs;
data.time = t;
data.csi = csi;
data.raw = round(raw);
data.amplitude = amp;
data.labels = labels;
end

