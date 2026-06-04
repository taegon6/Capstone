function result = detectPresence(amp, baselineIdx, currentIdx, opts)
%DETECTPRESENCE Threshold presence by variance/energy shift from baseline.
% 사람이 없는 앞 구간을 baseline으로 보고, 현재 구간의 CSI 변화량이 얼마나 달라졌는지 비교한다.
% 캡스톤 데모에서는 절대값보다 "기준 대비 변화"를 보는 방식이 환경 변화에 조금 더 안정적이다.
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
% variance는 움직임/반사 변화에 민감하고, energy는 전체 amplitude 크기 변화를 보조로 본다.
baseScore = mean(var(base, 0, 1, 'omitnan')) + mean(base(:).^2, 'omitnan') * 0.01;
currScore = mean(var(curr, 0, 1, 'omitnan')) + mean(curr(:).^2, 'omitnan') * 0.01;
delta = currScore - baseScore;

if isempty(opts.threshold) || opts.autoThreshold
    % baseline의 흔들림 정도를 기준으로 자동 threshold를 잡는다.
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
