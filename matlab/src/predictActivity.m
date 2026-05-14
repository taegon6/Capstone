function [label, scores] = predictActivity(model, amp, fs)
%PREDICTACTIVITY Predict activity label from a CSI amplitude window.
if nargin < 3
    fs = 50;
end
[feat, ~] = extractCsiFeatures(amp, fs, windowSec=min(2, size(amp,1)/fs), stepSec=2);
try
    [label, scores] = predict(model.classifier, feat(1, :));
catch
    label = predict(model.classifier, feat(1, :));
    scores = [];
end
end
