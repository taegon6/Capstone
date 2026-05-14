function result = estimateRespirationBPM(signalIn, fs, opts)
%ESTIMATERESPIRATIONBPM Estimate breathing BPM from static CSI amplitude.
arguments
    signalIn {mustBeNumeric}
    fs (1,1) double = 50
    opts.motionThreshold (1,1) double = 0.8
end

if ismatrix(signalIn) && size(signalIn, 2) > 1
    x = firstPcLocal(signalIn);
else
    x = signalIn(:);
end
x = fillmissing(x, 'linear', 'EndValues', 'nearest');
x = x - mean(x, 'omitnan');
motionScore = mean(abs(diff(x)), 'omitnan') / max(std(x, 'omitnan'), eps);

low = 0.1;
high = 0.5;
try
    filtered = bandpass(x, [low high], fs);
catch
    try
        [b, a] = butter(2, [low high] / (fs/2), 'bandpass');
        filtered = filtfilt(b, a, x);
    catch
        filtered = fftBandpassFallback(x, fs, low, high);
    end
end

nfft = max(256, 2^nextpow2(numel(filtered)));
y = abs(fft(filtered, nfft)).^2;
freq = (0:nfft-1) * fs / nfft;
mask = freq >= low & freq <= high;
[~, pos] = max(y(mask));
freqs = freq(mask);
peakFreq = freqs(pos);

result = struct();
result.bpm = peakFreq * 60;
result.peakFrequencyHz = peakFreq;
result.filteredSignal = filtered;
result.frequencyHz = freqs;
result.spectrum = y(mask);
result.motionScore = motionScore;
result.stable = motionScore < opts.motionThreshold;
if result.stable
    result.status = "stable";
else
    result.status = "unstable_motion";
end
end

function pc1 = firstPcLocal(x)
x = x - mean(x, 1, 'omitnan');
x(~isfinite(x)) = 0;
[~, ~, v] = svd(x, 'econ');
pc1 = x * v(:, 1);
end

function filtered = fftBandpassFallback(x, fs, low, high)
n = numel(x);
y = fft(x);
freq = (0:n-1).' * fs / n;
mirrorFreq = fs - freq;
mask = (freq >= low & freq <= high) | (mirrorFreq >= low & mirrorFreq <= high);
y(~mask) = 0;
filtered = real(ifft(y));
end
