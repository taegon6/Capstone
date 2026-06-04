function realtimeCsiActivityDashboard(port, modelFile, opts)
%REALTIMECSIACTIVITYDASHBOARD Presentation-friendly live CSI dashboard.
arguments
    port (1,:) char = 'COM11'
    modelFile (1,:) char = fullfile('data', 'models', 'phone_motion_csi_model.mat')
    opts.baudrate (1,1) double = 921600
    opts.maxSeconds (1,1) double = inf
    opts.windowPackets (1,1) double = 80
    opts.stepPackets (1,1) double = 20
    opts.maxRows (1,1) double = 400
end

loaded = load(modelFile, 'model', 'modelInfo');
model = loaded.model;
modelInfo = loaded.modelInfo;
targetSubcarriers = modelInfo.targetSubcarriers;

sp = serialport(port, opts.baudrate, 'Timeout', 0.2);
configureTerminator(sp, "LF");
flush(sp);
cleanup = onCleanup(@() delete(sp)); %#ok<NASGU>

state = initDashboard(port, modelInfo);
buffer = complex(zeros(0, targetSubcarriers));
numCsi = 0;
lastPredictionAt = 0;
startTime = tic;
historyLabels = strings(0, 1);
historyTimes = [];
diffHistory = [];
meanHistory = [];

while ishandle(state.figure) && toc(startTime) < opts.maxSeconds
    if sp.NumBytesAvailable == 0
        pause(0.02);
        drawnow limitrate;
        continue;
    end

    try
        line = string(readline(sp));
    catch
        continue;
    end
    line = strtrim(line);
    if isempty(line) || any(ismissing(line)) || strlength(line) == 0
        continue;
    end

    if startsWith(line, "CSI_STATUS")
        state.statusText.String = char(line);
        drawnow limitrate;
        continue;
    end
    if ~startsWith(line, "CSI_DATA")
        continue;
    end

    [raw, ok] = parseCsiLine(line);
    if ~ok
        continue;
    end
    csi = csiToComplex(raw);
    csi = normalizeCsiWidth(csi, targetSubcarriers);
    buffer = [buffer; csi]; %#ok<AGROW>
    numCsi = numCsi + 1;
    if size(buffer, 1) > opts.maxRows
        buffer = buffer(end-opts.maxRows+1:end, :);
    end

    amp = abs(buffer);
    meanHistory(end+1) = mean(amp(end, :), 'omitnan'); %#ok<AGROW>
    if numel(meanHistory) > 160
        meanHistory = meanHistory(end-159:end);
    end

    if size(buffer, 1) >= opts.windowPackets && (numCsi - lastPredictionAt) >= opts.stepPackets
        lastPredictionAt = numCsi;
        window = buffer(end-opts.windowPackets+1:end, :);
        label = predictWindow(model, modelInfo, window);
        diffEnergy = mean(abs(diff(abs(window), 1, 1)).^2, 'all', 'omitnan');

        historyLabels(end+1) = string(label); %#ok<AGROW>
        historyTimes(end+1) = toc(startTime); %#ok<AGROW>
        diffHistory(end+1) = diffEnergy; %#ok<AGROW>
        if numel(historyLabels) > 30
            historyLabels = historyLabels(end-29:end);
            historyTimes = historyTimes(end-29:end);
            diffHistory = diffHistory(end-29:end);
        end

        updateDashboard(state, string(label), diffEnergy, numCsi, historyLabels, historyTimes, diffHistory, meanHistory);
    else
        updateSignalPlot(state, meanHistory);
    end
    drawnow limitrate;
end
end

function state = initDashboard(port, modelInfo)
fig = figure('Name', 'CSI Patient Monitoring Demo', 'Color', 'w', ...
    'Position', [80 80 1100 720]);
tiledlayout(fig, 3, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

state.figure = fig;

nexttile([1 2]);
axis off;
state.titleText = text(0.02, 0.78, 'CSI Patient Monitoring Demo', ...
    'FontSize', 24, 'FontWeight', 'bold');
state.predictionText = text(0.02, 0.40, 'WAITING FOR CSI...', ...
    'FontSize', 34, 'FontWeight', 'bold', 'Color', [0.25 0.25 0.25]);
state.detailText = text(0.02, 0.12, sprintf('port=%s | model classes=%s', ...
    port, strjoin(string(categories(modelInfo.labels)), ', ')), ...
    'FontSize', 12, 'Color', [0.35 0.35 0.35]);
state.statusText = text(0.62, 0.12, 'CSI_STATUS pending', ...
    'FontSize', 11, 'Color', [0.35 0.35 0.35]);

nexttile;
state.gaugeAxis = gca;
bar(state.gaugeAxis, 0, 0.01, 'FaceColor', [0.2 0.45 0.85]);
ylim(state.gaugeAxis, [0 100]);
xlim(state.gaugeAxis, [0.5 1.5]);
xticks(state.gaugeAxis, []);
ylabel(state.gaugeAxis, 'diff energy');
title(state.gaugeAxis, 'CSI Change Level');
grid(state.gaugeAxis, 'on');

nexttile;
state.signalAxis = gca;
state.signalLine = plot(state.signalAxis, nan, nan, 'LineWidth', 1.4);
title(state.signalAxis, 'Recent CSI Mean Amplitude');
xlabel(state.signalAxis, 'Recent packet');
ylabel(state.signalAxis, 'Mean amplitude');
grid(state.signalAxis, 'on');

nexttile([1 2]);
state.historyAxis = gca;
state.historyScatter = scatter(state.historyAxis, nan, nan, 70, 'filled');
ylim(state.historyAxis, [0.5 3.5]);
yticks(state.historyAxis, [1 2 3]);
yticklabels(state.historyAxis, {'empty', 'static', 'moving'});
xlabel(state.historyAxis, 'Time (s)');
title(state.historyAxis, 'Prediction History');
grid(state.historyAxis, 'on');
end

function updateDashboard(state, label, diffEnergy, numCsi, historyLabels, historyTimes, diffHistory, meanHistory)
[displayLabel, color, yValue] = labelStyle(label);
state.predictionText.String = sprintf('CURRENT STATE: %s', displayLabel);
state.predictionText.Color = color;
state.detailText.String = sprintf('packets=%d | diff_energy=%.3f | updated=%s', ...
    numCsi, diffEnergy, datestr(now, 'HH:MM:SS'));

scaled = min(100, diffEnergy);
cla(state.gaugeAxis);
bar(state.gaugeAxis, 1, scaled, 'FaceColor', color);
ylim(state.gaugeAxis, [0 100]);
xlim(state.gaugeAxis, [0.5 1.5]);
xticks(state.gaugeAxis, []);
ylabel(state.gaugeAxis, 'diff energy');
title(state.gaugeAxis, sprintf('CSI Change Level: %.2f', diffEnergy));
grid(state.gaugeAxis, 'on');

updateSignalPlot(state, meanHistory);

ys = zeros(size(historyLabels));
colors = zeros(numel(historyLabels), 3);
for i = 1:numel(historyLabels)
    [~, c, y] = labelStyle(historyLabels(i));
    ys(i) = y;
    colors(i, :) = c;
end
cla(state.historyAxis);
scatter(state.historyAxis, historyTimes, ys, 70, colors, 'filled');
ylim(state.historyAxis, [0.5 3.5]);
yticks(state.historyAxis, [1 2 3]);
yticklabels(state.historyAxis, {'empty', 'static', 'moving'});
xlabel(state.historyAxis, 'Time (s)');
title(state.historyAxis, 'Prediction History');
grid(state.historyAxis, 'on');
if ~isempty(historyTimes)
    xlim(state.historyAxis, [max(0, historyTimes(end)-40), historyTimes(end)+2]);
end
end

function updateSignalPlot(state, meanHistory)
if isempty(meanHistory)
    return;
end
set(state.signalLine, 'XData', 1:numel(meanHistory), 'YData', meanHistory);
xlim(state.signalAxis, [1 max(10, numel(meanHistory))]);
valid = meanHistory(isfinite(meanHistory));
if ~isempty(valid)
    ylim(state.signalAxis, [min(valid)-1, max(valid)+1]);
end
end

function [displayLabel, color, yValue] = labelStyle(label)
switch string(label)
    case "empty"
        displayLabel = "EMPTY";
        color = [0.18 0.48 0.82];
        yValue = 1;
    case "static_person"
        displayLabel = "STATIC PERSON";
        color = [0.95 0.55 0.18];
        yValue = 2;
    case "moving_person"
        displayLabel = "MOVING PERSON";
        color = [0.82 0.18 0.18];
        yValue = 3;
    otherwise
        displayLabel = upper(string(label));
        color = [0.35 0.35 0.35];
        yValue = 2;
end
end

function csi = normalizeCsiWidth(csi, targetSubcarriers)
csi = csi(:).';
if numel(csi) >= targetSubcarriers
    csi = csi(1:targetSubcarriers);
else
    csi = [csi, complex(nan(1, targetSubcarriers - numel(csi)))];
end
end

function label = predictWindow(model, modelInfo, csiWindow)
prep = preprocessCsi(csiWindow);
[features, ~] = extractCsiFeatures( ...
    prep.amplitudeZ, modelInfo.fs, ...
    windowSec=modelInfo.windowSec, stepSec=modelInfo.windowSec);
featureTable = array2table(features(1, :), ...
    'VariableNames', matlab.lang.makeValidName(modelInfo.featureNames));
label = predictCsiActivityModel(model, featureTable);
end

