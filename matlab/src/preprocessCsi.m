function out = preprocessCsi(csiMatrix, opts)
%PREPROCESSCSI Compute amplitude/phase and normalize CSI over time.
arguments
    csiMatrix {mustBeNumeric}
    opts.window (1,1) double = 5
    opts.smoothWindow (1,1) double = 7
end

amp = abs(csiMatrix);
phase = unwrap(angle(csiMatrix), [], 1);
amp(~isfinite(amp)) = nan;
phase(~isfinite(phase)) = nan;

amp = fillmissing(amp, 'linear', 1, 'EndValues', 'nearest');
phase = fillmissing(phase, 'linear', 1, 'EndValues', 'nearest');
amp = fillmissing(amp, 'constant', 0);
phase = fillmissing(phase, 'constant', 0);

try
    ampClean = hampel(amp, opts.window);
catch
    ampClean = movmedian(amp, opts.window, 1);
end

try
    ampSmooth = sgolayfilt(ampClean, 2, max(3, opts.smoothWindow + mod(opts.smoothWindow+1,2)));
catch
    ampSmooth = movmean(ampClean, opts.smoothWindow, 1);
end
phaseSmooth = movmean(phase, opts.smoothWindow, 1);

mu = mean(ampSmooth, 1, 'omitnan');
sigma = std(ampSmooth, 0, 1, 'omitnan');
sigma(sigma < eps) = 1;
ampZ = (ampSmooth - mu) ./ sigma;
ampZ(~isfinite(ampZ)) = 0;

out = struct();
out.amplitude = amp;
out.phase = phase;
out.amplitudeClean = ampClean;
out.amplitudeSmooth = ampSmooth;
out.phaseSmooth = phaseSmooth;
out.amplitudeZ = ampZ;
end

