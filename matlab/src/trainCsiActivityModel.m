function model = trainCsiActivityModel(featureTable, featureNames, opts)
%TRAINCSIACTIVITYMODEL Train a CSI activity classifier with robust fallback.
arguments
    featureTable table
    featureNames
    opts.holdoutRatio (1,1) double = 0.3
    opts.method (1,:) char = 'auto'
    opts.seed (1,1) double = 7
    opts.showChart (1,1) logical = true
end

rng(opts.seed);
featureVars = matlab.lang.makeValidName(string(featureNames));
X = table2array(featureTable(:, featureVars));
Y = featureTable.label;

[trainIdx, testIdx] = stratifiedHoldout(Y, opts.holdoutRatio);
XTrain = X(trainIdx, :);
YTrain = Y(trainIdx);
XTest = X(testIdx, :);
YTest = Y(testIdx);

[mu, sigma] = normalizeStats(XTrain);
XTrainZ = applyNormalize(XTrain, mu, sigma);
XTestZ = applyNormalize(XTest, mu, sigma);

methodUsed = string(opts.method);
classifier = [];
try
    if strcmp(opts.method, 'auto') || strcmp(opts.method, 'fitcecoc')
        classifier = fitcecoc(XTrainZ, YTrain);
        methodUsed = "fitcecoc";
    elseif strcmp(opts.method, 'fitctree')
        classifier = fitctree(XTrainZ, YTrain);
        methodUsed = "fitctree";
    end
catch
    classifier = [];
end

if isempty(classifier)
    try
        classifier = fitctree(XTrainZ, YTrain);
        methodUsed = "fitctree";
    catch
        classifier = trainNearestCentroid(XTrainZ, YTrain);
        methodUsed = "nearest_centroid";
    end
end

YPred = predictCsiActivityModelInternal(classifier, XTestZ, methodUsed);
accuracy = mean(YPred == YTest);

if opts.showChart
    figure('Name', 'CSI Activity Classifier Confusion Matrix', 'Color', 'w');
    try
        confusionchart(YTest, YPred);
        title(sprintf('CSI activity classifier: %s, accuracy %.1f%%', methodUsed, accuracy * 100));
    catch
        plotConfusionFallback(YTest, YPred);
        title(sprintf('CSI activity classifier: %s, accuracy %.1f%%', methodUsed, accuracy * 100));
    end
end

model = struct();
model.classifier = classifier;
model.method = methodUsed;
model.featureNames = string(featureNames);
model.featureVars = featureVars;
model.mu = mu;
model.sigma = sigma;
model.accuracy = accuracy;
model.YTest = YTest;
model.YPred = YPred;
model.trainIdx = trainIdx;
model.testIdx = testIdx;
end

function [trainIdx, testIdx] = stratifiedHoldout(Y, holdoutRatio)
classes = categories(Y);
trainIdx = false(size(Y));
testIdx = false(size(Y));
for i = 1:numel(classes)
    idx = find(Y == classes{i});
    idx = idx(randperm(numel(idx)));
    nTest = max(1, round(numel(idx) * holdoutRatio));
    if numel(idx) > 1
        nTest = min(nTest, numel(idx) - 1);
    end
    testIdx(idx(1:nTest)) = true;
    trainIdx(idx(nTest+1:end)) = true;
end
end

function [mu, sigma] = normalizeStats(X)
mu = mean(X, 1, 'omitnan');
sigma = std(X, 0, 1, 'omitnan');
sigma(~isfinite(sigma) | sigma < eps) = 1;
mu(~isfinite(mu)) = 0;
end

function XZ = applyNormalize(X, mu, sigma)
XZ = (X - mu) ./ sigma;
XZ(~isfinite(XZ)) = 0;
end

function classifier = trainNearestCentroid(X, Y)
classes = categories(Y);
centroids = zeros(numel(classes), size(X, 2));
for i = 1:numel(classes)
    centroids(i, :) = mean(X(Y == classes{i}, :), 1, 'omitnan');
end
classifier = struct('classes', categorical(classes), 'centroids', centroids);
end

function yPred = predictCsiActivityModelInternal(classifier, X, methodUsed)
if methodUsed == "nearest_centroid"
    d = zeros(size(X, 1), numel(classifier.classes));
    for i = 1:numel(classifier.classes)
        delta = X - classifier.centroids(i, :);
        d(:, i) = sum(delta.^2, 2);
    end
    [~, pos] = min(d, [], 2);
    yPred = classifier.classes(pos);
else
    yPred = predict(classifier, X);
end
end

function plotConfusionFallback(YTest, YPred)
classes = categories(YTest);
cm = confusionmat(YTest, YPred, 'Order', categorical(classes));
imagesc(cm);
axis equal tight;
colorbar;
xticks(1:numel(classes));
yticks(1:numel(classes));
xticklabels(classes);
yticklabels(classes);
xlabel('Predicted');
ylabel('True');
end

