function plotCsiDashboard(data, prep, presence, motion)
%PLOTCSIDASHBOARD Plot compact CSI demo dashboard.
figure('Name', 'CSI Mock Dashboard', 'Color', 'w');
tiledlayout(3, 1);

nexttile;
imagesc(data.time, 1:size(prep.amplitudeSmooth, 2), prep.amplitudeSmooth.');
axis xy;
xlabel('Time (s)');
ylabel('Subcarrier');
title('CSI Amplitude Heatmap');
colorbar;

nexttile;
plot(data.time, mean(prep.amplitudeZ, 2), 'LineWidth', 1.2);
xlabel('Time (s)');
ylabel('Mean z-score');
title(sprintf('Presence: %d, score %.3f / threshold %.3f', presence.presence, presence.score, presence.threshold));
grid on;

nexttile;
stairs(motion.time, motion.motion, 'LineWidth', 1.5);
hold on;
plot(motion.time, motion.score ./ max(motion.score + eps), 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Motion');
title('Motion Detection Windows');
ylim([-0.1 1.2]);
grid on;
end

