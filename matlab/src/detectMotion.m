function result = detectMotion(amp, fs, opts)
%DETECTMOTION Classify windows as static or moving.
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

