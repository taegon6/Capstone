function labels = predictCsiActivityModel(model, featureTable)
%PREDICTCSIACTIVITYMODEL Predict activity labels for a feature table.
X = table2array(featureTable(:, model.featureVars));
X = (X - model.mu) ./ model.sigma;
X(~isfinite(X)) = 0;

if model.method == "nearest_centroid"
    d = zeros(size(X, 1), numel(model.classifier.classes));
    for i = 1:numel(model.classifier.classes)
        delta = X - model.classifier.centroids(i, :);
        d(:, i) = sum(delta.^2, 2);
    end
    [~, pos] = min(d, [], 2);
    labels = model.classifier.classes(pos);
else
    labels = predict(model.classifier, X);
end
end

