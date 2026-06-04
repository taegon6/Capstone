function result = detectMotion(amp, fs, opts)
%DETECTMOTION Classify windows as static or moving.
% 움직임은 연속 packet 사이의 변화량이 커지는 특징이 있다.
% 따라서 diff_energy를 중심으로 보고, variance를 조금 섞어 window별 static/moving을 판단한다.
arguments
    amp {mustBeNumeric}
    fs (1,1) double = 50
    opts.windowSec (1,1) double = 1
    opts.stepSec (1,1) double = 0.5
    opts.threshold double = []
end

[features, names, times] = extractCsiFeatures(amp, fs, windowSec=opts.windowSec, stepSec=opts.stepSec);
diffIdx = find(strcmp(names, 'diff_energy'));
varIdx = find(strcmp(names, 'variance'));
score = features(:, diffIdx) + 0.2 * features(:, varIdx);

if isempty(opts.threshold)
    % 데이터마다 scale이 다르므로 median + MAD 방식으로 threshold를 자동 추정한다.
    threshold = median(score) + 1.5 * mad(score, 1);
else
    threshold = opts.threshold;
end

result = struct();
result.time = times;
result.score = score;
result.threshold = threshold;
result.motion = score > threshold;
result.label = strings(size(score));
result.label(result.motion) = "moving";
result.label(~result.motion) = "static";
end
