function out = preprocessCsi(csiMatrix, opts)
%PREPROCESSCSI Compute amplitude/phase and normalize CSI over time.
% raw CSI를 바로 쓰면 값이 튀는 경우가 많아서 여기서 한번 정리한다.
% amplitude/phase 계산 후 smoothing과 z-score normalization을 적용한다.
arguments
    csiMatrix {mustBeNumeric}
    opts.window (1,1) double = 5
    opts.smoothWindow (1,1) double = 7
end

amp = abs(csiMatrix);
phase = unwrap(angle(csiMatrix), [], 1);
amp(~isfinite(amp)) = nan;
phase(~isfinite(phase)) = nan;

% 깨진 packet 때문에 생긴 NaN/Inf 보정
amp = fillmissing(amp, 'linear', 1, 'EndValues', 'nearest');
phase = fillmissing(phase, 'linear', 1, 'EndValues', 'nearest');
amp = fillmissing(amp, 'constant', 0);
phase = fillmissing(phase, 'constant', 0);

try
    % 튀는 값 제거
    ampClean = hampel(amp, opts.window);
catch
    % hampel이 안 되면 median filter로 대체
    ampClean = movmedian(amp, opts.window, 1);
end

try
    % smoothing
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

% 중간 결과도 같이 반환해서 그래프 확인할 때 사용
out = struct();
out.amplitude = amp;
out.phase = phase;
out.amplitudeClean = ampClean;
out.amplitudeSmooth = ampSmooth;
out.phaseSmooth = phaseSmooth;
out.amplitudeZ = ampZ;
end
