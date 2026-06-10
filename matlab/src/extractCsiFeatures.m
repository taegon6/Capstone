function [features, featureNames, windowTimes] = extractCsiFeatures(amp, fs, opts)
%EXTRACTCSIFEATURES Extract sliding-window CSI amplitude features.
% CSI amplitude를 window 단위로 잘라서 통계 feature를 만든다.
% 분류 모델은 이 feature matrix를 입력으로 사용한다.
arguments
    amp {mustBeNumeric}
    fs (1,1) double = 50
    opts.windowSec (1,1) double = 2
    opts.stepSec (1,1) double = 0.5
end

amp(~isfinite(amp)) = 0;
win = max(2, round(opts.windowSec * fs));
step = max(1, round(opts.stepSec * fs));
n = size(amp, 1);
starts = 1:step:max(1, n - win + 1);
featureNames = {'mean','std','variance','energy','max','min','range', ...
    'diff_energy','dominant_frequency','spectral_energy','pca1_mean','pca1_std'};
features = zeros(numel(starts), numel(featureNames));
windowTimes = zeros(numel(starts), 1);

for k = 1:numel(starts)
    idx = starts(k):min(n, starts(k)+win-1);
    x = amp(idx, :);
    flat = x(:);
    d = diff(x, 1, 1);
    % window 안의 주파수 성분 확인
    [domFreq, specEnergy] = dominantSpectrumFeature(mean(x, 2), fs);
    % subcarrier가 많아서 PCA 1번 성분도 feature로 사용
    pca1 = firstPrincipalComponent(x);
    features(k, :) = [mean(flat), std(flat), var(flat), mean(flat.^2), ...
        max(flat), min(flat), range(flat), mean(d(:).^2), domFreq, ...
        specEnergy, mean(pca1), std(pca1)];
    windowTimes(k) = (idx(1)-1) / fs;
end
end

function [domFreq, specEnergy] = dominantSpectrumFeature(x, fs)
% 평균 amplitude의 FFT peak를 찾는다.
x = x(:) - mean(x, 'omitnan');
if numel(x) < 4 || all(abs(x) < eps)
    domFreq = 0;
    specEnergy = 0;
    return;
end
y = abs(fft(x)).^2;
freq = (0:numel(y)-1) * fs / numel(y);
half = 2:floor(numel(y)/2);
[peak, pos] = max(y(half));
domFreq = freq(half(pos));
specEnergy = sum(y(half)) / numel(half);
if isempty(peak)
    domFreq = 0;
end
end

function pc1 = firstPrincipalComponent(x)
% pca가 안 되는 환경이면 SVD로 비슷하게 처리
x = x - mean(x, 1, 'omitnan');
x(~isfinite(x)) = 0;
if size(x, 2) == 1
    pc1 = x(:, 1);
    return;
end
try
    [~, score] = pca(x, 'NumComponents', 1);
    pc1 = score(:, 1);
catch
    [~, ~, v] = svd(x, 'econ');
    pc1 = x * v(:, 1);
end
end
