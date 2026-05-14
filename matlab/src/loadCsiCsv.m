function csiMatrix = loadCsiCsv(filename, opts)
%LOADCSICSV Load a CSV or text log containing CSI_DATA lines.
arguments
    filename (1,:) char
    opts.removeInvalidBytes (1,1) logical = false
end

lines = readlines(filename);
rows = {};
maxLen = 0;
for i = 1:numel(lines)
    [raw, ok] = parseCsiLine(lines(i));
    if ok
        csi = csiToComplex(raw, removeInvalidBytes=opts.removeInvalidBytes);
        rows{end+1} = csi; %#ok<AGROW>
        maxLen = max(maxLen, numel(csi));
    end
end

csiMatrix = complex(nan(numel(rows), maxLen));
for i = 1:numel(rows)
    csiMatrix(i, 1:numel(rows{i})) = rows{i};
end
end

