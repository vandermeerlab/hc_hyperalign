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
    Q_norm{p_i} = normalize_Q('concat', Q{p_i});
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

%% Plot example sessions for procedure
sr_i = 1;
tar_i = 10;
idx = {sr_i, tar_i};
data = TC;

% Project [L, R] to PCA space.
NumComponents = 10;
for p_i = 1:length(data)
    [proj_Q{p_i}, eigvecs{p_i}, pca_mean{p_i}] = perform_pca(data{p_i}, NumComponents);
end
%% Input and PCA
figure;
for i = 1:length(idx)
    subplot(2, 2, 2*i-1);
    imagesc([data{idx{i}}.left, data{idx{i}}.right]);
    ylabel('Neurons');
    xlabel('Locations');
    set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 40);

    subplot(2, 2, 2*i);
    plot_L = plot_3d_trajectory(proj_Q{idx{i}}.left);
    plot_L.Color = 'r';
    hold on;
    plot_R = plot_3d_trajectory(proj_Q{idx{i}}.right);
    plot_R.Color = 'b';
    if i == 1
        plot_L.Color(4) = 0.5;
        plot_R.Color(4) = 0.5;
    end
    hold on;
end
%% Common space
figure;
hyper_input = {proj_Q{sr_i}, proj_Q{tar_i}};
[aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);
[~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}', 'scaling', false);
predicted_aligned = p_transform(M, aligned_left{2});

s_plot_L = plot_3d_trajectory(aligned_left{1});
s_plot_L.Color = 'r';
s_plot_L.Color(4) = 0.5;
hold on;
s_plot_R = plot_3d_trajectory(aligned_right{1});
s_plot_R.Color = 'b';
s_plot_R.Color(4) = 0.5;
hold on;
t_plot_L = plot_3d_trajectory(aligned_left{2});
t_plot_L.Color = 'r';
hold on;
t_plot_R = plot_3d_trajectory(aligned_right{2});
t_plot_R.Color = 'b';
hold on;
p_plot_R = plot_3d_trajectory(predicted_aligned);
p_plot_R.Color = 'g';

%% Project back to PCA space and input space
figure;
project_back_pca = inv_p_transform(transforms{2}, [aligned_left{2}, predicted_aligned]);
w_len = size(aligned_left{2}, 2);
pro_pca_left = project_back_pca(:, 1:w_len);
pro_pca_right = project_back_pca(:, w_len+1:end);
subplot(1, 2, 1);
plot_L = plot_3d_trajectory(pro_pca_left);
plot_L.Color = 'r';
hold on;
plot_R = plot_3d_trajectory(proj_Q{tar_i}.right);
plot_R.Color = 'b';
hold on;
p_plot_R = plot_3d_trajectory(pro_pca_right);
p_plot_R.Color = 'g';
hold on;

project_back_Q = eigvecs{tar_i} * project_back_pca + pca_mean{tar_i};
pro_Q_left = project_back_Q(:, 1:w_len);
pro_Q_right = project_back_Q(:, w_len+1:end);

subplot(1, 2, 2);
imagesc([pro_Q_left, pro_Q_right]);
ylabel('Neurons');
xlabel('Locations');
set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 40);
