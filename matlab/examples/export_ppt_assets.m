clear; clc;

scriptDir = fileparts(mfilename('fullpath'));
projectRoot = fullfile(scriptDir, '..', '..');
addpath(genpath(fullfile(projectRoot, 'matlab')));

assetDir = fullfile(projectRoot, 'data', 'ppt_assets');
if ~exist(assetDir, 'dir')
    mkdir(assetDir);
end

fprintf('Exporting PPT assets to %s\n', assetDir);

exportSystemArchitecture(fullfile(assetDir, '01_system_architecture_ppt.png'));
exportPhoneSummary(projectRoot, fullfile(assetDir, '02_phone_csi_summary_ppt.png'));
exportMotionFeatureScatter(projectRoot, fullfile(assetDir, '03_phone_motion_feature_scatter_ppt.png'));
exportEmergencyFeatureScatter(projectRoot, fullfile(assetDir, '04_emergency_feature_scatter_ppt.png'));
exportDashboardPreview(fullfile(assetDir, '05_realtime_dashboard_preview_ppt.png'));

copyResultImage(projectRoot, 'phone_csi_dataset_comparison.png', assetDir, '06_phone_csi_dataset_comparison.png');
copyResultImage(projectRoot, 'phone_motion_ai_confusion.png', assetDir, '07_phone_motion_ai_confusion.png');
copyResultImage(projectRoot, 'phone_realtime_model_confusion.png', assetDir, '08_phone_realtime_model_confusion.png');
copyResultImage(projectRoot, 'mock_emergency_fall_ai_confusion.png', assetDir, '09_mock_emergency_fall_ai_confusion.png');
copyResultImage(projectRoot, 'public_homehar_activity_ai_confusion.png', assetDir, '10_public_homehar_activity_ai_confusion.png');
copyResultImage(projectRoot, 'public_homehar_summary.png', assetDir, '11_public_homehar_summary.png');

writeAssetReadme(assetDir);

fprintf('Done. PPT assets are ready.\n');

function exportSystemArchitecture(outFile)
    fig = makeFigure('System Architecture');
    ax = axes(fig);
    axis(ax, [0 1 0 1]);
    axis(ax, 'manual');
    axis(ax, 'off');
    hold(ax, 'on');

    boxes = {
        [0.05 0.56 0.18 0.18], 'ESP32-S3', 'CSI logger';
        [0.29 0.56 0.18 0.18], 'Serial / CSV', 'CSI_DATA lines';
        [0.53 0.56 0.18 0.18], 'MATLAB', 'parser + preprocess';
        [0.77 0.56 0.18 0.18], 'Decision', 'presence / motion';
        [0.29 0.20 0.18 0.18], 'Features', 'energy, variance, PCA';
        [0.53 0.20 0.18 0.18], 'ML / Rule', 'activity, emergency';
        [0.77 0.20 0.18 0.18], 'Dashboard', 'demo status';
    };

    for i = 1:size(boxes, 1)
        pos = boxes{i, 1};
        rectangle(ax, 'Position', pos, 'Curvature', 0.06, ...
            'FaceColor', [0.93 0.98 0.98], 'EdgeColor', [0.02 0.35 0.40], 'LineWidth', 1.6);
        text(ax, pos(1) + pos(3)/2, pos(2) + pos(4)*0.63, boxes{i, 2}, ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 15, ...
            'Color', [0.02 0.12 0.20], 'Interpreter', 'none');
        text(ax, pos(1) + pos(3)/2, pos(2) + pos(4)*0.34, boxes{i, 3}, ...
            'HorizontalAlignment', 'center', 'FontSize', 12, ...
            'Color', [0.20 0.25 0.30], 'Interpreter', 'none');
    end

    drawArrow(ax, [0.23 0.65], [0.29 0.65]);
    drawArrow(ax, [0.47 0.65], [0.53 0.65]);
    drawArrow(ax, [0.71 0.65], [0.77 0.65]);
    drawArrow(ax, [0.62 0.56], [0.38 0.38]);
    drawArrow(ax, [0.47 0.29], [0.53 0.29]);
    drawArrow(ax, [0.71 0.29], [0.77 0.29]);

    title(ax, 'CSI-only Capstone System Flow', 'FontSize', 22, 'FontWeight', 'bold');
    exportgraphics(fig, outFile, 'Resolution', 220);
    close(fig);
end

function exportPhoneSummary(projectRoot, outFile)
    csvFile = fullfile(projectRoot, 'data', 'results', 'phone_csi_dataset_summary.csv');
    T = readtable(csvFile, 'TextType', 'string');
    labels = cleanLabels(T.label);
    labelCats = categorical(labels, labels, 'Ordinal', true);

    fig = makeFigure('Phone CSI Summary');
    layout = tiledlayout(fig, 1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(layout, 'ESP32 CSI Data Collected with Phone Hotspot', 'FontSize', 20, 'FontWeight', 'bold');

    nexttile(layout);
    bar(labelCats, T.packets, 'FaceColor', [0.09 0.45 0.56]);
    ylabel('Packets');
    title('Collected Packets');
    grid on;

    nexttile(layout);
    bar(labelCats, T.mean_diff_energy, 'FaceColor', [0.93 0.46 0.18]);
    ylabel('Mean diff energy');
    title('Motion-sensitive Feature');
    grid on;

    nexttile(layout);
    ratio = T.moving_windows ./ T.total_windows;
    bar(labelCats, ratio, 'FaceColor', [0.20 0.62 0.38]);
    ylim([0 1]);
    ylabel('Moving window ratio');
    title('Detected Motion Windows');
    grid on;

    exportgraphics(fig, outFile, 'Resolution', 220);
    close(fig);
end

function exportMotionFeatureScatter(projectRoot, outFile)
    csvFile = fullfile(projectRoot, 'data', 'results', 'phone_motion_feature_dataset.csv');
    T = readtable(csvFile, 'TextType', 'string');
    exportFeatureScatter(T, outFile, 'Phone CSI Activity Feature Space', ...
        'variance', 'diff_energy', 'Variance', 'Temporal diff energy');
end

function exportEmergencyFeatureScatter(projectRoot, outFile)
    csvFile = fullfile(projectRoot, 'data', 'results', 'mock_emergency_fall_feature_dataset.csv');
    T = readtable(csvFile, 'TextType', 'string');
    exportFeatureScatter(T, outFile, 'Mock Emergency Event Feature Space', ...
        'range', 'diff_energy', 'Amplitude range', 'Temporal diff energy');
end

function exportFeatureScatter(T, outFile, figTitle, xName, yName, xLabelText, yLabelText)
    fig = makeFigure(figTitle);
    ax = axes(fig);
    hold(ax, 'on');
    labels = string(T.label);
    uniqueLabels = unique(labels, 'stable');
    colors = [0.09 0.45 0.56; 0.93 0.46 0.18; 0.20 0.62 0.38; 0.46 0.32 0.70; 0.75 0.22 0.26];

    for i = 1:numel(uniqueLabels)
        idx = labels == uniqueLabels(i);
        color = colors(mod(i-1, size(colors, 1)) + 1, :);
        scatter(ax, T.(xName)(idx), T.(yName)(idx), 54, color, 'filled', ...
            'MarkerFaceAlpha', 0.78, 'DisplayName', char(uniqueLabels(i)));
    end

    grid(ax, 'on');
    xlabel(ax, xLabelText);
    ylabel(ax, yLabelText);
    title(ax, figTitle, 'FontSize', 20, 'FontWeight', 'bold');
    lgd = legend(ax, 'Location', 'bestoutside');
    lgd.Interpreter = 'none';
    set(ax, 'FontSize', 12);
    exportgraphics(fig, outFile, 'Resolution', 220);
    close(fig);
end

function exportDashboardPreview(outFile)
    rng(7);
    fig = makeFigure('Realtime Dashboard Preview');
    ax = axes(fig);
    axis(ax, [0 1 0 1]);
    axis(ax, 'off');
    title(ax, 'Realtime CSI Dashboard Preview', 'FontSize', 22, 'FontWeight', 'bold');

    drawPanel(ax, [0.04 0.62 0.28 0.22], 'Presence', 'human candidate', [0.20 0.62 0.38]);
    drawPanel(ax, [0.36 0.62 0.28 0.22], 'Motion', 'moving', [0.93 0.46 0.18]);
    drawPanel(ax, [0.68 0.62 0.28 0.22], 'Emergency', 'normal', [0.09 0.45 0.56]);

    x = linspace(0, 1, 120);
    motionTrace = 0.25 + 0.10*sin(2*pi*x*3) + 0.45*exp(-((x-0.65)/0.08).^2);
    ampTrace = 0.55 + 0.04*sin(2*pi*x*6) + 0.03*randn(size(x));

    axes('Parent', fig, 'Position', [0.08 0.34 0.84 0.18]);
    plot(x, motionTrace, 'Color', [0.93 0.46 0.18], 'LineWidth', 2.2);
    grid on;
    title('Temporal Difference Energy');
    ylabel('Energy');
    xticks([]);

    axes('Parent', fig, 'Position', [0.08 0.10 0.84 0.18]);
    plot(x, ampTrace, 'Color', [0.09 0.45 0.56], 'LineWidth', 2.2);
    grid on;
    title('Mean CSI Amplitude');
    xlabel('Recent packets');
    ylabel('Amplitude');

    exportgraphics(fig, outFile, 'Resolution', 220);
    close(fig);
end

function drawPanel(ax, pos, heading, value, color)
    rectangle(ax, 'Position', pos, 'Curvature', 0.05, ...
        'FaceColor', [0.97 0.98 0.99], 'EdgeColor', color, 'LineWidth', 2);
    text(ax, pos(1) + 0.03, pos(2) + pos(4)*0.68, heading, ...
        'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.15 0.18 0.22], 'Interpreter', 'none');
    text(ax, pos(1) + 0.03, pos(2) + pos(4)*0.34, value, ...
        'FontSize', 18, 'FontWeight', 'bold', 'Color', color, 'Interpreter', 'none');
end

function drawArrow(ax, startPoint, endPoint)
    color = [0.18 0.25 0.30];
    plot(ax, [startPoint(1) endPoint(1)], [startPoint(2) endPoint(2)], ...
        'Color', color, 'LineWidth', 1.8);

    direction = endPoint - startPoint;
    direction = direction ./ max(norm(direction), eps);
    normal = [-direction(2), direction(1)];
    headLength = 0.018;
    headWidth = 0.010;
    p1 = endPoint;
    p2 = endPoint - headLength * direction + headWidth * normal;
    p3 = endPoint - headLength * direction - headWidth * normal;
    patch(ax, [p1(1) p2(1) p3(1)], [p1(2) p2(2) p3(2)], color, ...
        'EdgeColor', color);
end

function fig = makeFigure(name)
    fig = figure('Name', name, 'Color', 'w', 'Position', [100 100 1280 720], 'Visible', 'off');
end

function labels = cleanLabels(labels)
    labels = string(labels);
    labels = replace(labels, "_phone", "");
    labels = replace(labels, "_", " ");
end

function copyResultImage(projectRoot, sourceName, assetDir, targetName)
    src = fullfile(projectRoot, 'data', 'results', sourceName);
    dst = fullfile(assetDir, targetName);
    if exist(src, 'file')
        copyfile(src, dst);
    else
        warning('Missing result image: %s', src);
    end
end

function writeAssetReadme(assetDir)
    readmeFile = fullfile(assetDir, 'README.md');
    fid = fopen(readmeFile, 'w');
    cleanup = onCleanup(@() fclose(fid));
    fprintf(fid, '# PPT Asset Pack\n\n');
    fprintf(fid, 'These images were exported for the GPT Pro PPT workflow.\n\n');
    fprintf(fid, 'Recommended upload order:\n\n');
    fprintf(fid, '1. `01_system_architecture_ppt.png`\n');
    fprintf(fid, '2. `02_phone_csi_summary_ppt.png`\n');
    fprintf(fid, '3. `03_phone_motion_feature_scatter_ppt.png`\n');
    fprintf(fid, '4. `04_emergency_feature_scatter_ppt.png`\n');
    fprintf(fid, '5. `05_realtime_dashboard_preview_ppt.png`\n');
    fprintf(fid, '6. `06_phone_csi_dataset_comparison.png`\n');
    fprintf(fid, '7. `07_phone_motion_ai_confusion.png`\n');
    fprintf(fid, '8. `08_phone_realtime_model_confusion.png`\n');
    fprintf(fid, '9. `09_mock_emergency_fall_ai_confusion.png`\n');
    fprintf(fid, '10. `10_public_homehar_activity_ai_confusion.png`\n');
    fprintf(fid, '11. `11_public_homehar_summary.png`\n\n');
    fprintf(fid, 'Use these images with `docs/gpt_pro_ppt_prompt.md` and `docs/ppt_source_materials.md`.\n');
end
