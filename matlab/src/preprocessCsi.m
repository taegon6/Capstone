function out = preprocessCsi(csiMatrix, opts)
%PREPROCESSCSI Compute amplitude/phase and normalize CSI over time.
% CSI는 환경 노이즈와 순간적인 튐이 많기 때문에 바로 분류에 쓰기 어렵다.
% 이 함수에서는 amplitude/phase를 계산한 뒤 결측값 처리, 이상치 완화, smoothing,
% subcarrier별 z-score normalization을 적용해서 feature 추출에 적합한 형태로 만든다.
arguments
    csiMatrix {mustBeNumeric}
    opts.window (1,1) double = 5
    opts.smoothWindow (1,1) double = 7
end

amp = abs(csiMatrix);
phase = unwrap(angle(csiMatrix), [], 1);
amp(~isfinite(amp)) = nan;
phase(~isfinite(phase)) = nan;

% 실시간 로그에서는 일부 packet이 깨질 수 있으므로 NaN/Inf를 안전하게 보정한다.
amp = fillmissing(amp, 'linear', 1, 'EndValues', 'nearest');
phase = fillmissing(phase, 'linear', 1, 'EndValues', 'nearest');
amp = fillmissing(amp, 'constant', 0);
phase = fillmissing(phase, 'constant', 0);

try
    % Hampel filter가 있으면 큰 튐 값을 완화한다.
    ampClean = hampel(amp, opts.window);
catch
    % Toolbox 차이로 hampel이 없을 때는 moving median으로 대체한다.
    ampClean = movmedian(amp, opts.window, 1);
end

try
    % Savitzky-Golay smoothing은 파형 형태를 비교적 보존하면서 노이즈를 줄인다.
    ampSmooth = sgolayfilt(ampClean, 2, max(3, opts.smoothWindow + mod(opts.smoothWindow+1,2)));
catch
    ampSmooth = movmean(ampClean, opts.smoothWindow, 1);
end
phaseSmooth = movmean(phase, opts.smoothWindow, 1);

mu = mean(ampSmooth, 1, 'omitnan');
sigma = std(ampSmooth, 0, 1, 'omitnan');
sigma(sigma < eps) = 1;
ampZ = (ampSmooth - mu) ./ sigma;
ampZ(~isfinite(ampZ)) = 0;

% 원본 amplitude부터 정규화 결과까지 모두 남겨서 발표/디버깅에서 비교할 수 있게 했다.
out = struct();
out.amplitude = amp;
out.phase = phase;
out.amplitudeClean = ampClean;
out.amplitudeSmooth = ampSmooth;
out.phaseSmooth = phaseSmooth;
out.amplitudeZ = ampZ;
end
