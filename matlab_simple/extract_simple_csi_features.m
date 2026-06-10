function [featureTable, featureNames, debug] = extract_simple_csi_features(csiMatrix, label, fs)
% CSI matrix에서 간단한 window feature를 뽑는다.
% feature는 mean, variance, diff energy, range 정도만 사용했다.

if nargin < 3
    fs = 50;
end

amp = abs(csiMatrix);
amp(~isfinite(amp)) = 0;

% 값이 너무 튀는 것을 줄이고 subcarrier별 scale을 맞춘다.
ampSmooth = movmean(amp, 5, 1);
mu = mean(ampSmooth, 1);
sigma = std(ampSmooth, 0, 1);
sigma(sigma < eps) = 1;
ampZ = (ampSmooth - mu) ./ sigma;

win = round(2.0 * fs);
step = round(0.5 * fs);
starts = 1:step:max(1, size(ampZ, 1)-win+1);

featureNames = {'mean_abs','variance','energy','diff_energy','range','pca1_std'};
X = zeros(numel(starts), numel(featureNames));

for k = 1:numel(starts)
    idx = starts(k):min(starts(k)+win-1, size(ampZ, 1));
    x = ampZ(idx, :);
    d = diff(x, 1, 1);
    flat = x(:);
    pca1 = simplePca1(x);

    X(k, :) = [
        mean(abs(flat))
        var(flat)
        mean(flat.^2)
        mean(d(:).^2)
        max(flat) - min(flat)
        std(pca1)
    ];
end

featureTable = array2table(X, 'VariableNames', featureNames);
featureTable.label = repmat(string(label), height(featureTable), 1);

debug = struct();
debug.amplitude = amp;
debug.amplitudeZ = ampZ;
debug.windowStart = starts(:) / fs;
end

function pc1 = simplePca1(x)
x = x - mean(x, 1);
x(~isfinite(x)) = 0;
if size(x, 2) < 2
    pc1 = x(:, 1);
    return;
end
[~, ~, v] = svd(x, 'econ');
pc1 = x * v(:, 1);
end

