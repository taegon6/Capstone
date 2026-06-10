function csi = csiToComplex(raw, opts)
%CSITOCOMPLEX Convert interleaved ESP32 CSI integers to complex values.
% ESP32 raw CSI는 imag, real 순서로 들어온다고 보고 복소수로 바꾼다.
% 앞쪽 4바이트를 빼야 하는 로그도 있어서 옵션으로 남겨뒀다.
arguments
    raw {mustBeNumeric}
    opts.removeInvalidBytes (1,1) logical = false
end

raw = raw(:).';
if opts.removeInvalidBytes && numel(raw) > 4
    % 필요할 때 앞 4개 값을 버림
    raw = raw(5:end);
end
if mod(numel(raw), 2) == 1
    % real/imag pair를 맞추려고 마지막 값 하나는 버림
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
