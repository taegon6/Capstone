function model = trainActivityClassifier(opts)
%TRAINACTIVITYCLASSIFIER Train a simple classifier on mock activity features.
arguments
    opts.showChart (1,1) logical = true
    opts.fs (1,1) double = 50
end

classes = ["static","walking","sitting","standing_up","fall"];
X = [];
Y = strings(0, 1);
for c = 1:numel(classes)
    for rep = 1:25
        amp = mockActivityWindow(classes(c), opts.fs);
        [feat, names] = extractCsiFeatures(amp, opts.fs, windowSec=2, stepSec=2);
        X = [X; feat(1, :)]; %#ok<AGROW>
        Y(end+1, 1) = classes(c); %#ok<AGROW>
    end
end

cv = cvpartition(Y, 'HoldOut', 0.3);
XTrain = X(training(cv), :);
YTrain = Y(training(cv));
XTest = X(test(cv), :);
YTest = Y(test(cv));

try
    classifier = fitcecoc(XTrain, YTrain);
catch
    classifier = fitctree(XTrain, YTrain);
end
YPred = predict(classifier, XTest);
accuracy = mean(YPred == YTest);

if opts.showChart
    figure('Name', 'Mock Activity Confusion Chart', 'Color', 'w');
    confusionchart(YTest, YPred);
    title(sprintf('Mock activity accuracy %.1f%%', accuracy * 100));
end

model = struct();
model.classifier = classifier;
model.featureNames = names;
model.accuracy = accuracy;
model.classes = classes;
end

function amp = mockActivityWindow(label, fs)
t = (0:1/fs:2-1/fs).';
sc = 1:52;
amp = 20 + 0.3 * randn(numel(t), numel(sc));
switch label
    case "static"
        amp = amp + 0.2 * sin(2*pi*0.2*t) .* sin(sc/8);
    case "walking"
        amp = amp + 2.0 * sin(2*pi*1.5*t) .* sin(sc/5) + 0.8 * randn(size(amp));
    case "sitting"
        amp = amp + (t > 0.7) .* (1.5 * exp(-((sc-24).^2)/120));
    case "standing_up"
        amp = amp + (t > 0.8) .* (-1.2 * exp(-((sc-28).^2)/110));
    case "fall"
        impulse = exp(-((t-1.0).^2)/0.01);
        amp = amp + 5.0 * impulse .* sin(sc/3);
end
end

