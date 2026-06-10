function [raw, ok] = parseCsiLine(line)
%PARSECSILINE Parse ESP32-CSI-Tool style CSI_DATA array from one log line.
% serial 로그 한 줄에서 [1,2,3,...] 형태의 CSI 배열만 뽑는다.
% CSI_DATA가 아닌 줄은 그냥 ok=false로 넘긴다.
raw = [];
ok = false;

try
    if isstring(line)
        line = char(line);
    end
    % 기본 로그 형식: "CSI_DATA,...,[raw values]"
    token = regexp(line, 'CSI_DATA\s*,?\s*\[([^\]]+)\]', 'tokens', 'once');
    if isempty(token)
        % 테스트할 때는 배열만 넣어도 파싱되게 했다.
        token = regexp(line, '\[([-\d,\s]+)\]', 'tokens', 'once');
    end
    if isempty(token)
        return;
    end
    parts = regexp(token{1}, ',', 'split');
    values = str2double(strtrim(parts));
    if isempty(values) || any(isnan(values))
        return;
    end
    raw = values(:).';
    ok = true;
catch
    raw = [];
    ok = false;
end
end
