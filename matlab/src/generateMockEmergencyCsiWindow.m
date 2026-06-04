function amp = generateMockEmergencyCsiWindow(label, fs, opts)
%GENERATEMOCKEMERGENCYCSIWINDOW Mock CSI window for normal vs fall emergency.
arguments
    label (1,:) char
    fs (1,1) double = 50
    opts.durationSec (1,1) double = 2
    opts.numSubcarriers (1,1) double = 52
end

t = (0:1/fs:opts.durationSec-1/fs).';
sc = 1:opts.numSubcarriers;
amp = 20 + 0.35 * randn(numel(t), numel(sc));

switch string(label)
    case "normal_static"
        amp = amp + 0.2 * sin(2*pi*0.2*t) .* sin(sc/8);
    case "normal_walking"
        amp = amp + 1.3 * sin(2*pi*1.3*t) .* sin(sc/5) + 0.45 * randn(size(amp));
    case "normal_sitting"
        transition = 1 ./ (1 + exp(-(t - 0.9) * 10));
        amp = amp + transition .* (1.0 * exp(-((sc-24).^2)/130));
    case "normal_standing_up"
        transition = 1 ./ (1 + exp(-(t - 0.9) * 10));
        amp = amp - transition .* (0.9 * exp(-((sc-30).^2)/140));
    case "emergency_fall"
        impact = exp(-((t - 0.85).^2) / 0.006);
        postFallStill = t > 1.1;
        amp = amp + 6.0 * impact .* sin(sc/3);
        amp = amp + postFallStill .* (1.5 * exp(-((sc-20).^2)/100));
        amp = amp + 0.25 * randn(size(amp));
    otherwise
        error('Unknown label: %s', label);
end
end

