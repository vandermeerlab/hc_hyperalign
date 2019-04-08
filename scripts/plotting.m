%% Set Labels as Restrction Types
set(gca, 'XTick', 1:19, 'XTickLabel', restrictionLabels);
set(gca, 'YTick', 1:19, 'YTickLabel', restrictionLabels);

%% Create polished imagesc and histogram (for comparison with zscores of shuffles and ID)
subplot(2, 2, 1);
imagesc(out_zscore_mat,'AlphaData', ~isnan(out_zscore_mat));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
% set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 35);

subplot(2, 2, 3);
histogram(out_zscore_mat, 50);
title('zscores of Hypertransform');
ylabel('# of pairs');
xlabel(sprintf('< 0: %.2f %%, Bino-p: %.2f', out_zscore_prop * 100, bino_p_mean));
% set(gca, 'yticklabel', [], 'FontSize', 35)

subplot(2, 2, 2);
imagesc(out_M_ID,'AlphaData', ~isnan(out_M_ID));
colorbar;
% set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 35);

subplot(2, 2, 4);
histogram(out_M_ID, 50)
title('Hypertransform - ID');
xlabel(sprintf('< 0: %.2f %%, Bino-p: %.2f', out_id_prop * 100, bino_p_id));
% set(gca, 'yticklabel', [], 'FontSize', 35)

%% Create polished imagesc and histogram (for proportion)
subplot(1, 2, 1);
imagesc(out_actual_sf_mat,'AlphaData', ~isnan(out_actual_sf_mat));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
% set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 35);

subplot(1, 2, 2);
histogram(out_actual_sf_mat, 20)
ylabel('# of pairs');
xlabel('Proportion > shuffled');
% set(gca, 'yticklabel', [], 'FontSize', 35)

%% Create polished imagesc and histogram (for comparison with mean of shuffles and ID)
subplot(2, 2, 1);
imagesc(out_actual_mean_sf,'AlphaData', ~isnan(out_actual_mean_sf));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
% set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 35);

subplot(2, 2, 3);
binsize = 25;
bin_edges = round(min(out_actual_mean_sf(:)), -2):binsize:round(max(out_actual_mean_sf(:)), -2);
bin_centers = bin_edges(1:end-1) + binsize ./ 2;
this_h = histc(out_actual_mean_sf(:), bin_edges);

bar(bin_centers, this_h(1:end-1));
title('Hypertransform - mean of shuffled');
ylabel('# of pairs');
xlabel(sprintf('< 0: %.2f %%, Bino-p: %.2f', out_actual_mean_sf_prop * 100, bino_p_mean));
% set(gca, 'yticklabel', [], 'FontSize', 35)

subplot(2, 2, 2);
imagesc(out_M_ID,'AlphaData', ~isnan(out_M_ID));
colorbar;
% set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 35);

subplot(2, 2, 4);
histogram(out_M_ID, 50)
title('Hypertransform - ID');
xlabel(sprintf('< 0: %.2f %%, Bino-p: %.2f', out_id_prop * 100, bino_p_id));
% set(gca, 'yticklabel', [], 'FontSize', 35)

%% Create M v.s ID figure
M = out_actual_dists(~isnan(out_actual_dists))';
ID = out_id_dists(~isnan(out_id_dists))';
plot([zeros(size(M)); ones(size(ID))], [M; ID]); hold on;
plot([zeros(size(M)); ones(size(ID))], [M; ID], '.', 'MarkerSize', 10);
xlim([-0.1 1.1])
title(sprintf('Welch’s t-test: %.2f (%.2f %%), Binomial CDF: %.2f %%', t_h, t_p, bino_p));

%% Create Q figures
for p_i = 1:length(Q)
    subplot(2, 1, 1)
    imagesc([Q{p_i}.left, Q{p_i}.right]);
    colorbar;
    subplot(2, 1, 2)
    Q_norm{p_i} = normalize_Q('sub_mean', Q{p_i});
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

% Summary of main results
%% Plot example inputs
norm_inputs = {Q, Q_norm_ind, Q_norm_concat, Q_norm_sub};
norm_methods = {'none', 'ind', 'concat', 'sub_mean'};
for n_i = 1:length(norm_inputs)
    subplot(3, 4, n_i)
    imagesc([norm_inputs{n_i}{1}.left, norm_inputs{n_i}{1}.right]);
    colorbar;
    % set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 40);
    title(norm_methods{n_i});
end

%% Hyperalignment procedure
rng(mean('hyperalignment'));
for nm_i = 1:length(norm_methods)
    cfg_pre = [];
    cfg_pre.normalization = norm_methods{nm_i};
    [actual_dists_mat, id_dists_mat] = predict_with_L_R(cfg_pre, Q);

    n_shuffles = 1000;
    sf_dists_mat  = zeros(length(Q), length(Q), n_shuffles);

    for i = 1:n_shuffles
        cfg_pre.shuffled = 1;
        [s_actual_dists_mat] = predict_with_L_R(cfg_pre, Q);
        sf_dists_mat(:, :, i) = s_actual_dists_mat;
    end

    % Calculate common metrics
    cfg.use_adr_data = 0;
    % Proportion of actual distance smaller than shuffled distances
    actual_sf_mat = sum(actual_dists_mat < sf_dists_mat, 3);
    out_actual_sf_mat = set_withsubj_nan(cfg, actual_sf_mat) / 1000;

    % Matrix of differences between actual distance (identity distance) and mean of shuffled distance.
    actual_mean_sf = actual_dists_mat - mean(sf_dists_mat, 3);
    out_actual_mean_sf = set_withsubj_nan(cfg, actual_mean_sf);

    % Proportion of distance obtained from M smaller than mean of shuffled distance.
    out_actual_mean_sf_prop = sum(sum(out_actual_mean_sf < 0)) / sum(sum(~isnan(out_actual_mean_sf)));

    % Proportion of distance obtained from M smaller than identity mapping
    out_actual_dists = set_withsubj_nan(cfg, actual_dists_mat);
    out_id_dists = set_withsubj_nan(cfg, id_dists_mat);
    out_id_prop = sum(sum(out_actual_dists < out_id_dists)) / sum(sum(~isnan(out_actual_dists)));

    % Binomial stats
    bino_p_mean = calculate_bino_p(sum(sum(out_actual_mean_sf < 0)), sum(sum(~isnan(out_actual_mean_sf))), 0.5);
    bino_p_id = calculate_bino_p(sum(sum(out_actual_dists < out_id_dists)), sum(sum(~isnan(out_actual_dists))), 0.5);

    subplot(5, 4, 4 + nm_i)
    imagesc(out_actual_sf_mat,'AlphaData', ~isnan(out_actual_sf_mat));
    colorbar;

    subplot(5, 4, 8 + nm_i)
    histogram(out_actual_sf_mat, 20)
    title(sprintf('M < ID: %.2f %%, Bino-p: %.2f', out_id_prop * 100, bino_p_id));

    subplot(5, 4, 12 + nm_i)
    imagesc(out_actual_mean_sf,'AlphaData', ~isnan(out_actual_mean_sf));
    colorbar;

    binsize = 10;
    bin_edges = round(min(out_actual_mean_sf(:)), -1):binsize:round(max(out_actual_mean_sf(:)), -1);
    bin_centers = bin_edges(1:end-1) + binsize ./ 2;
    this_h = histc(out_actual_mean_sf(:), bin_edges);

    subplot(5, 4, 16 + nm_i)
    bar(bin_centers, this_h(1:end-1));
    title(sprintf('< 0: %.2f %%, Bino-p: %.2f', out_actual_mean_sf_prop * 100, bino_p_mean));
end

% Summary of correlation results
%% Cell-by-cell correlation
norm_inputs = {Q, Q_norm_ind, Q_norm_concat, Q_norm_sub};
for n_i = 1:length(norm_inputs)
    data = norm_inputs{n_i};
    mean_coefs = zeros(1, length(data));
    std_coefs = zeros(1, length(data));

    for i = 1:length(data)
        whiten_left = data{i}.left + 0.001 * rand(size(data{i}.left));
        whiten_right = data{i}.right + 0.001 * rand(size(data{i}.right));

        cell_coefs = zeros(size(whiten_left, 1), 1);
        for j = 1:size(whiten_left, 1)
            [coef] = corrcoef(whiten_left(j, :), whiten_right(j, :));
            cell_coefs(j) = coef(1, 2);
        end
        mean_coefs(i) = mean(cell_coefs, 'omitnan');
        std_coefs(i) = std(cell_coefs, 'omitnan');
    end

    subplot(3, 4, 4 + n_i)
    errorbar(1:length(mean_coefs), mean_coefs, std_coefs);
    xlabel('corrcoefs'); ylabel('sessions')
end

%% Location-by-location (time-by-time) analysis
norm_inputs = {Q, Q_norm_ind, Q_norm_concat, Q_norm_sub};
for n_i = 1:length(norm_inputs)
    data = norm_inputs{n_i};
    data = cellfun(@(x) [x.left, x.right], data, 'UniformOutput', false);
    coefs = cell(1, length(data));

    w_len = size(data{1}, 2);
    for i = 1:length(data)
        w_coefs = zeros(w_len, w_len);
        for j = 1:w_len
            for k = 1:w_len
                [coef] = corrcoef(data{i}(:, j), data{i}(:, k));
                w_coefs(j, k) = coef(1, 2);
            end
        end
        coefs{i} = w_coefs;
    end

    mean_coefs = mean(cat(3, coefs{:}), 3);
    subplot(3, 4, 8 + n_i)
    imagesc(mean_coefs);
    colorbar;
    xlabel('L -> R'); ylabel('L -> R');
end
