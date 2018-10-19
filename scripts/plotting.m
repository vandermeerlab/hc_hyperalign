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

out_zscore_mat = set_withsubj_nan(zscore_mat);
imagesc(out_zscore_mat,'AlphaData', ~isnan(out_zscore_mat));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
title('Z-score of distances excluding within subjects')

out_percent_mat = set_withsubj_nan(percent_mat);
imagesc(out_percent_mat,'AlphaData', ~isnan(out_percent_mat));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
title('Percentile of distances excluding within subjects')

% Set Labels as Restrction Types
set(gca, 'XTick', 1:19, 'XTickLabel', restrictionLabels);
set(gca, 'YTick', 1:19, 'YTickLabel', restrictionLabels);

% Plot shuffle distance histogram and true distance (by shuffling Q matrix)
for i = 1:length(Q)
    subplot(length(Q), 1, i)
    histogram(rand_dists{i})
    line([dist{i}, dist{i}], ylim, 'LineWidth', 2, 'Color', 'r')
    line([dist_LR{i}, dist_LR{i}], ylim, 'LineWidth', 2, 'Color', 'g')
    title('Distance betweeen using M* and its own aligned right trials')
end
