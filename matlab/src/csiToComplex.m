function csi = csiToComplex(raw, opts)
%CSITOCOMPLEX Convert interleaved ESP32 CSI integers to complex values.
arguments
    raw {mustBeNumeric}
    opts.removeInvalidBytes (1,1) logical = false
end

raw = raw(:).';
if opts.removeInvalidBytes && numel(raw) > 4
    raw = raw(5:end);
end
if mod(numel(raw), 2) == 1
    raw = raw(1:end-1);
end
if isempty(raw)
    csi = complex([]);
    return;
end

imagPart = raw(1:2:end);
realPart = raw(2:2:end);
csi = complex(realPart, imagPart);
end

