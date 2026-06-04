function realtimeCsiActivityMonitor(port, modelFile, opts)
%REALTIMECSIACTIVITYMONITOR Classify live ESP32 CSI windows from Serial.
arguments
    port (1,:) char = 'COM11'
    modelFile (1,:) char = fullfile('data', 'models', 'phone_motion_csi_model.mat')
    opts.baudrate (1,1) double = 921600
    opts.maxSeconds (1,1) double = inf
    opts.windowPackets (1,1) double = 80
    opts.stepPackets (1,1) double = 20
    opts.maxRows (1,1) double = 400
    opts.removeInvalidBytes (1,1) logical = false
end

loaded = load(modelFile, 'model', 'modelInfo');
model = loaded.model;
modelInfo = loaded.modelInfo;
targetSubcarriers = modelInfo.targetSubcarriers;

sp = serialport(port, opts.baudrate, 'Timeout', 0.5);
configureTerminator(sp, "LF");
flush(sp);
cleanup = onCleanup(@() clear sp); %#ok<NASGU>

buffer = complex(zeros(0, targetSubcarriers));
lastPredictionAt = 0;
startTime = tic;
numCsi = 0;

fprintf('Realtime CSI activity monitor\n');
fprintf('port=%s baud=%d model=%s\n', port, opts.baudrate, modelFile);
fprintf('classes=%s\n', strjoin(string(categories(modelInfo.labels)), ', '));
fprintf('Press Ctrl+C to stop.\n\n');

while toc(startTime) < opts.maxSeconds
    line = readline(sp);
    if ~startsWith(strtrim(line), "CSI_DATA")
        if startsWith(strtrim(line), "CSI_STATUS")
            fprintf('%s\n', strtrim(line));
        end
        continue;
    end

    [raw, ok] = parseCsiLine(line);
    if ~ok
        continue;
    end
    csi = csiToComplex(raw, removeInvalidBytes=opts.removeInvalidBytes);
    csi = normalizeCsiWidth(csi, targetSubcarriers);
    buffer = [buffer; csi]; %#ok<AGROW>
    numCsi = numCsi + 1;

    if size(buffer, 1) > opts.maxRows
        buffer = buffer(end-opts.maxRows+1:end, :);
    end

    if size(buffer, 1) >= opts.windowPackets && (numCsi - lastPredictionAt) >= opts.stepPackets
        lastPredictionAt = numCsi;
        window = buffer(end-opts.windowPackets+1:end, :);
        label = predictWindow(model, modelInfo, window);
        diffEnergy = mean(abs(diff(abs(window), 1, 1)).^2, 'all');
        fprintf('[%6.1fs] packets=%d prediction=%s diff_energy=%.4f\n', ...
            toc(startTime), numCsi, string(label), diffEnergy);
    end
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

