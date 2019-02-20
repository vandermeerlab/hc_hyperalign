imagesc(zscore_mat);
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
title('Z-score of distances including within subjects')

imagesc(out_zscore_mat,'AlphaData', ~isnan(out_zscore_mat));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
title('Z-score of distances excluding within subjects')
% set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 60);

% Histoggram of z-scores
histogram(out_zscore_mat, 20)

% Set Labels as Restrction Types
set(gca, 'XTick', 1:19, 'XTickLabel', restrictionLabels);
set(gca, 'YTick', 1:19, 'YTickLabel', restrictionLabels);

%% Create polished imagesc and histogram as in main result
subplot(1, 2, 1);
imagesc(out_actual_sf_mat,'AlphaData', ~isnan(out_actual_sf_mat));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 35);

subplot(1, 2, 2);
histogram(out_actual_sf_mat, 20)
ylabel('# of pairs');
xlabel('Proportion > shuffled');
set(gca, 'yticklabel', [], 'FontSize', 35)

%% Create Q figures
for p_i = 1:length(Q)
    subplot(2, 1, 1)
    imagesc([Q{p_i}.left, Q{p_i}.right]);
    colorbar;
    subplot(2, 1, 2)
    imagesc([Q_norm{p_i}.left, Q_norm{p_i}.right]);
    colorbar;
    saveas(gcf, sprintf('Q_%d.jpg', p_i));
end

%% Create TC figures
for p_i = 1:length(TC)
    subplot(2, 1, 1)
    imagesc([TC{p_i}.left, TC{p_i}.right]);
    colorbar;
    subplot(2, 1, 2)
    imagesc([TC_norm{p_i}.left, TC_norm{p_i}.right]);
    colorbar;
    saveas(gcf, sprintf('TC_%d.jpg', p_i));
end

%%
histogram(sf_dists)
line([actual_dist, actual_dist], ylim, 'LineWidth', 2, 'Color', 'r')
% line([id_dist, id_dist], ylim, 'LineWidth', 2, 'Color', 'g')
set(gca, 'LineWidth', 1, 'xticklabel', [], 'yticklabel',[], 'FontSize', 24);
xlabel('Distances'); ylabel('Distribution');

%% Plot example sessions
figure;
s_plot_L = plot_3d_trajectory(aligned_left{1});
s_plot_L.Color = 'r';
hold on;
s_plot_R = plot_3d_trajectory(aligned_right{1});
s_plot_R.Color = 'b';
hold on;
t_plot_L = plot_3d_trajectory(aligned_left{2});
t_plot_L.Color = 'r';
t_plot_L.Color(4) = 0.5;
hold on;
t_plot_R = plot_3d_trajectory(aligned_right{2});
t_plot_R.Color = 'b';
t_plot_R.Color(4) = 0.5;
hold on;
p_plot_R = plot_3d_trajectory(predicted);
p_plot_R.Color = 'g';
lgd = legend([s_plot_L, s_plot_R, t_plot_L, t_plot_R, p_plot_R], ...
    ["Rat 1 - L", "Rat 1 - R", "Rat 2 - L", "Rat 2 - R", "Rat 2 - Predicted R"]);
lgd.FontSize = 30;
legend boxoff;
