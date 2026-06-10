function data = load_or_mock_csi(projectRoot)
% 실제 ESP32 로그가 있으면 읽고, 없으면 mock CSI를 만든다.
% 출력 data는 label과 csi matrix를 가진 struct array이다.

logDir = fullfile(projectRoot, 'data', 'csi_logs');
files = {
    'empty',         fullfile(logDir, '20260604_102541_empty_phone_COM11.log')
    'static_person', fullfile(logDir, '20260604_102703_static_person_phone_COM11.log')
    'moving_person', fullfile(logDir, '20260604_102849_moving_person_phone_COM11.log')
};

data = struct('label', {}, 'csi', {});
for i = 1:size(files, 1)
    label = files{i, 1};
    file = files{i, 2};
    if exist(file, 'file')
        csi = readEsp32CsiLog(file);
    else
        csi = [];
    end

    if isempty(csi)
        csi = makeMockCsi(label, 450, 96);
    end

    data(end+1).label = label; %#ok<AGROW>
    data(end).csi = csi;
end

% fall 데이터는 실제 환자 데이터가 없어서 mock으로만 만든다.
data(end+1).label = 'fall_candidate';
data(end).csi = makeMockCsi('fall_candidate', 450, 96);
end

function csiMatrix = readEsp32CsiLog(file)
fid = fopen(file, 'r');
if fid < 0
    csiMatrix = [];
    return;
end
cleanup = onCleanup(@() fclose(fid));

rows = {};
targetWidth = [];
while ~feof(fid)
    line = fgetl(fid);
    raw = parseCsiArray(line);
    if isempty(raw)
        continue;
    end

    csi = rawToComplex(raw);
    if isempty(csi)
        continue;
    end

    if isempty(targetWidth)
        targetWidth = numel(csi);
    end
    csi = fixWidth(csi, targetWidth);
    rows{end+1, 1} = csi; %#ok<AGROW>
end

if isempty(rows)
    csiMatrix = [];
else
    csiMatrix = vertcat(rows{:});
end
end

function raw = parseCsiArray(line)
raw = [];
if ~ischar(line) && ~isstring(line)
    return;
end
line = char(line);
token = regexp(line, '\[([-\d,\s]+)\]', 'tokens', 'once');
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
raw = raw(:).';
if mod(numel(raw), 2) == 1
    raw = raw(1:end-1);
end
if isempty(raw)
    csi = [];
    return;
end
imagPart = raw(1:2:end);
realPart = raw(2:2:end);
csi = complex(realPart, imagPart);
end

function csi = fixWidth(csi, targetWidth)
if numel(csi) > targetWidth
    csi = csi(1:targetWidth);
elseif numel(csi) < targetWidth
    csi(end+1:targetWidth) = 0;
end
end

function csi = makeMockCsi(label, nPacket, nSubcarrier)
t = (1:nPacket).' / 50;
base = 1 + 0.05 * randn(nPacket, nSubcarrier);
sub = linspace(0, 2*pi, nSubcarrier);

switch string(label)
    case "empty"
        amp = base + 0.02 * sin(2*pi*0.2*t + sub);
    case "static_person"
        amp = base + 0.08 * sin(2*pi*0.25*t + sub);
    case "moving_person"
        amp = base + 0.25 * sin(2*pi*1.2*t + sub) + 0.12 * randn(nPacket, nSubcarrier);
    otherwise
        amp = base;
        fallPoint = round(nPacket * 0.45);
        amp(fallPoint:fallPoint+25, :) = amp(fallPoint:fallPoint+25, :) + 0.9 * hann(26);
        amp(fallPoint+40:end, :) = amp(fallPoint+40:end, :) + 0.04 * randn(nPacket-fallPoint-39, nSubcarrier);
end

phase = 0.2 * randn(nPacket, nSubcarrier);
csi = amp .* exp(1j * phase);
end

