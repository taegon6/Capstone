function realtimeSerialMonitor(port, baudrate, opts)
%REALTIMESERIALMONITOR Read CSI serial lines and print live summary.
arguments
    port (1,:) char
    baudrate (1,1) double = 921600
    opts.maxLines (1,1) double = 500
    opts.removeInvalidBytes (1,1) logical = false
end

sp = serialport(port, baudrate);
configureTerminator(sp, "LF");
cleanup = onCleanup(@() clear sp); %#ok<NASGU>

buffer = complex([]);
fprintf('Listening on %s at %d baud...\n', port, baudrate);
for i = 1:opts.maxLines
    line = readline(sp);
    [raw, ok] = parseCsiLine(line);
    if ~ok
        continue;
    end
    csi = csiToComplex(raw, removeInvalidBytes=opts.removeInvalidBytes);
    if isempty(buffer)
        buffer = csi;
    else
        width = min(size(buffer, 2), numel(csi));
        buffer = [buffer(:, 1:width); csi(1:width)]; %#ok<AGROW>
    end
    if size(buffer, 1) >= 20
        prep = preprocessCsi(buffer);
        recent = mean(prep.amplitudeZ(max(1,end-19):end, :), 'all');
        fprintf('line=%d subcarriers=%d recent_mean_z=%.3f\n', i, numel(csi), recent);
    end
end
end

