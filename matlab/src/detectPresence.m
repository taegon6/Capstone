function result = detectPresence(amp, baselineIdx, currentIdx, opts)
%DETECTPRESENCE Threshold presence by variance/energy shift from baseline.
% 앞쪽 baseline 구간과 현재 구간의 CSI 변화량을 비교한다.
arguments
    amp {mustBeNumeric}
    baselineIdx = []
    currentIdx = []
    opts.threshold double = []
    opts.autoThreshold (1,1) logical = true
end

if isempty(baselineIdx)
    baselineIdx = 1:max(5, floor(size(amp,1) * 0.2));
end
if isempty(currentIdx)
    currentIdx = 1:size(amp,1);
end

base = amp(baselineIdx, :);
curr = amp(currentIdx, :);
% variance를 주로 보고 energy는 보조로 사용
baseScore = mean(var(base, 0, 1, 'omitnan')) + mean(base(:).^2, 'omitnan') * 0.01;
currScore = mean(var(curr, 0, 1, 'omitnan')) + mean(curr(:).^2, 'omitnan') * 0.01;
delta = currScore - baseScore;

if isempty(opts.threshold) || opts.autoThreshold
    % baseline 흔들림 기준으로 threshold 설정
    threshold = max(0.05, 2.5 * std(mean(base, 2, 'omitnan')));
else
    threshold = opts.threshold;
end

result = struct();
result.presence = delta > threshold;
result.score = delta;
result.threshold = threshold;
result.baselineScore = baseScore;
result.currentScore = currScore;
end
