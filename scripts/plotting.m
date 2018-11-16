imagesc(zscore_mat);
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
title('Z-score of distances including within subjects')

imagesc(percent_mat);
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
title('Percentile of distances including within subjects')

imagesc(out_zscore_mat,'AlphaData', ~isnan(out_zscore_mat));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
title('Z-score of distances excluding within subjects')
% set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 60);


imagesc(out_percent_mat,'AlphaData', ~isnan(out_percent_mat));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
title('Percentile of distances excluding within subjects')

% Set Labels as Restrction Types
set(gca, 'XTick', 1:19, 'XTickLabel', restrictionLabels);
set(gca, 'YTick', 1:19, 'YTickLabel', restrictionLabels);

% Histoggram of z-scores and percentiles
histogram(out_zscore_mat)
title('Histogram of z-scores with matched trials')

histogram(out_percent_mat)
title('Histogram of percentiles with matched trials')

for i = 1:length(aligned_source)
    ali_source = aligned_source{ex_i};
    ali_target = aligned_target{ex_i};

    % Plot example sessions
    figure;
    s_plot = plot_3d_trajectory(ali_source);
    s_plot.Color = 'r';
    hold on;
    t_plot = plot_3d_trajectory(ali_target);
    t_plot.Color = 'b';
    
    lgd = legend([s_plot, t_plot], ["Rat 1 - Actual Left", "Rat 1 - Actual Right"]);
    lgd.FontSize = 30;
    legend boxoff;
    
    saveas(gcf, sprintf('without_pca_same_rat_%d.jpg', i));
end

for i = 1:length(aligned_source)
    ali_source = aligned_source{i};
    ali_target = aligned_target{i};
    ali_predict = predicted{i};
    
    figure;
    s_plot = plot_3d_trajectory(ali_source);
    hold on;
    t_plot = plot_3d_trajectory(ali_target);
    hold on;
    p_plot = plot_3d_trajectory(ali_predict);
    grid on;
    lgd = legend([s_plot, t_plot, p_plot], ["Rat 2 - Actual Left", "Rat 2 - Actual Right", "Rat 2 - Predicted Right"]);
    lgd.FontSize = 30;
    legend boxoff;
    
    saveas(gcf, sprintf('without_pca_diff_rat_%d.jpg', i));
end

for p_i = 1:length(TC)
    subplot(2, 1, 1)
    imagesc(corrcoef(aligned_left{p_i}(1:3, :)));
    colorbar;
    subplot(2, 1, 2)
    imagesc(corrcoef(aligned_right{p_i}(1:3, :)));
    colorbar;
    saveas(gcf, sprintf('TC_align3_corrcoef_%d.jpg', p_i));
end

histogram(rand_dists_mat{15, 2})
line([dist_mat(15, 2), dist_mat(15, 2)], ylim, 'LineWidth', 2, 'Color', 'r')
line([dist_LR_mat(15, 2), dist_LR_mat(15, 2)], ylim, 'LineWidth', 2, 'Color', 'g')
set(gca, 'LineWidth', 1, 'xticklabel', [], 'yticklabel',[], 'FontSize', 24);
xlabel('Distances'); ylabel('Distribution');

% % Plot shuffle distance histogram and true distance (by shuffling Q matrix)
% for i = 1:length(Q)
%     subplot(length(Q), 1, i)
%     histogram(rand_dists{i})
%     line([dist{i}, dist{i}], ylim, 'LineWidth', 2, 'Color', 'r')
%     line([dist_LR{i}, dist_LR{i}], ylim, 'LineWidth', 2, 'Color', 'g')
%     title('Distance betweeen using M* and its own aligned right trials')
% end

%% Plot the data
% mat = proj_Q{1};
% figinx = 101;
% 
% colors = linspecer(2);
% % need to fix the trial level
% for i = 1: numel(mat.left)
%     Q_left(:,:,i) = mat.left{i};
%     figure(figinx);
%     p1=plot3(Q_left(1, :,i), Q_left(2, :,i), Q_left(3, :,i), '-','color',[0 0 1],'LineWidth',3);
%     p1.Color(4) = 0.1;
%     hold on;
% end
% grid on;
% 
% for i = 1:numel(mat.right)
%     Q_right(:,:,i) = mat.right{i};
%     figure(figinx);
%     p1=plot3(Q_right(1, :,i), Q_right(2, :,i), Q_right(3, :,i), '-','color',[1 0 0],'LineWidth',3);
%     p1.Color(4) = 0.1;
%     hold on;
% end
% grid on;
% 
% % plot the average
% all_right = mean(mean_proj_Q.right{1},3);
% figure(figinx);
% p1=plot3(all_right(1, :), all_right(2, :), all_right(3, :), '-','color',[1 0 0],'LineWidth',3);
% p1.Color(4) = 1;
% xlabel('Component 1');ylabel('Component 2');zlabel('Component 3')
% 
% all_left = mean(mean_proj_Q.left{1},3);
% figure(figinx);hold on
% p1=plot3(all_left(1, :), all_left(2, :), all_left(3, :), '-','color',[0 0 1],'LineWidth',3);
% p1.Color(4) = 1;
% xlabel('Component 1');ylabel('Component 2');zlabel('Component 3')
% title('Blue - Left, Red - Right')

% Plot trajectory
% left
% trajectory_plotter(5, aligned_left{1}', aligned_left{2}', aligned_left{3}');
%
% right
% trajectory_plotter(5, aligned_right{1}', aligned_right{2}', aligned_right{3}');
%
% non-aligned right trials
% trajectory_plotter(5, mean_proj_Q.right{1}', mean_proj_Q.right{2}', mean_proj_Q.right{3}');
