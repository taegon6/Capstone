function [raw, ok] = parseCsiLine(line)
%PARSECSILINE Parse ESP32-CSI-Tool style CSI_DATA array from one log line.
raw = [];
ok = false;

try
    if isstring(line)
        line = char(line);
    end
    token = regexp(line, 'CSI_DATA\s*,?\s*\[([^\]]+)\]', 'tokens', 'once');
    if isempty(token)
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

