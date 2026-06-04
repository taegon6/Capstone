function csi = csiToComplex(raw, opts)
%CSITOCOMPLEX Convert interleaved ESP32 CSI integers to complex values.
% ESP32 CSI raw 값은 보통 imag, real, imag, real 순서로 들어온다.
% MATLAB 분석에서는 complex(real, imag) 형태가 편하므로 여기서 복소수 벡터로 변환한다.
% 일부 로그에서 앞쪽 invalid byte가 섞이는 경우를 대비해 removeInvalidBytes 옵션도 남겨두었다.
arguments
    raw {mustBeNumeric}
    opts.removeInvalidBytes (1,1) logical = false
end

raw = raw(:).';
if opts.removeInvalidBytes && numel(raw) > 4
    % ESP32-CSI-Tool 계열 로그에서 앞 4바이트가 분석에 방해될 때 사용한다.
    raw = raw(5:end);
end
if mod(numel(raw), 2) == 1
    % real/imag 쌍을 맞추기 위해 홀수 길이면 마지막 값은 버린다.
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
