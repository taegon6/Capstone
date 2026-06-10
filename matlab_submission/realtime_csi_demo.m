function realtime_csi_demo(port)
% ESP32가 연결되어 있을 때 CSI가 들어오는지 확인하는 코드
% 예: realtime_csi_demo("COM11")

if nargin < 1
    port = "COM11";
end

baudrate = 921600;
sp = serialport(port, baudrate, 'Timeout', 0.2);
configureTerminator(sp, "LF");
flush(sp);

fprintf('Reading CSI from %s at %d baud...\n', port, baudrate);
fprintf('Stop with Ctrl+C.\n');

count = 0;
ampHistory = [];

figure('Name', 'Realtime CSI check', 'Color', 'w');
while ishandle(gcf)
    line = readline(sp);
    raw = parseLine(line);
    if isempty(raw)
        continue;
    end
    csi = rawToComplex(raw);
    if isempty(csi)
        continue;
    end

    count = count + 1;
    ampHistory(end+1) = mean(abs(csi)); %#ok<AGROW>
    if numel(ampHistory) > 150
        ampHistory = ampHistory(end-149:end);
    end

    plot(ampHistory, 'LineWidth', 1.5);
    grid on;
    title(sprintf('CSI packets: %d', count));
    ylabel('Mean amplitude');
    xlabel('Recent packet');
    drawnow limitrate;
end
end

function raw = parseLine(line)
raw = [];
token = regexp(char(line), '\[([-\d,\s]+)\]', 'tokens', 'once');
if isempty(token)
    return;
end
values = str2double(strtrim(split(token{1}, ',')));
if any(isnan(values))
    return;
end
raw = values(:).';
end

function csi = rawToComplex(raw)
if mod(numel(raw), 2) == 1
    raw = raw(1:end-1);
end
imagPart = raw(1:2:end);
realPart = raw(2:2:end);
csi = complex(realPart, imagPart);
end
