function [raw, ok] = parseCsiLine(line)
%PARSECSILINE Parse ESP32-CSI-Tool style CSI_DATA array from one log line.
% ESP32에서 serial로 넘어오는 로그는 상태 메시지와 CSI_DATA가 섞여 있다.
% 이 함수는 그중 [1,2,3,...] 형태의 CSI raw 배열만 꺼내서 숫자 벡터로 바꾼다.
% 형식이 맞지 않는 줄은 에러를 내지 않고 ok=false로 반환해서 실시간 수집이 멈추지 않게 했다.
raw = [];
ok = false;

try
    if isstring(line)
        line = char(line);
    end
    % 기본 ESP32 CSI 로그 형식: "CSI_DATA,...,[raw values]"
    token = regexp(line, 'CSI_DATA\s*,?\s*\[([^\]]+)\]', 'tokens', 'once');
    if isempty(token)
        % 데모/테스트용으로 대괄호 배열만 들어온 경우도 허용한다.
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
