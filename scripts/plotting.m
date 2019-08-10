%% Set Labels as Restrction Types
set(gca, 'XTick', 1:19, 'XTickLabel', restrictionLabels);
set(gca, 'YTick', 1:19, 'YTickLabel', restrictionLabels);

%% Create polished imagesc and histogram (for comparison with zscores of shuffles)
subplot(2, 4, 1);
imagesc(out_zscore_mat,'AlphaData', ~isnan(out_zscore_mat));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
set(gca, 'xticklabel', [], 'yticklabel', []);

subplot(2, 4, 5);
histogram(out_zscore_mat, 50);
title('zscores of Hypertransform');
ylabel('# of pairs');
xlabel(sprintf('< 0: %.2f %%, Signrank: %.2f', out_zscore_prop * 100, sr_p_zscore));
set(gca, 'yticklabel', [])

%% Create polished imagesc and histogram (for proportion)
subplot(2, 4, 3);
imagesc(out_actual_sf_mat,'AlphaData', ~isnan(out_actual_sf_mat));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
set(gca, 'xticklabel', [], 'yticklabel', []);

subplot(2, 4, 7);
histogram(out_actual_sf_mat, 20)
ylabel('# of pairs');
title('Proportion > shuffled');
set(gca, 'yticklabel', [])

%% Create polished imagesc and histogram (for comparison with mean of shuffles and ID)
subplot(2, 4, 2);
imagesc(out_actual_mean_sf,'AlphaData', ~isnan(out_actual_mean_sf));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
set(gca, 'xticklabel', [], 'yticklabel', []);

subplot(2, 4, 6);
binsize = 10;
bin_edges = round(min(out_actual_mean_sf(:)), -1):binsize:round(max(out_actual_mean_sf(:)), -1);
bin_centers = bin_edges(1:end-1) + binsize ./ 2;
this_h = histc(out_actual_mean_sf(:), bin_edges);

bar(bin_centers, this_h(1:end-1));
title('Hypertransform - mean of shuffled');
ylabel('# of pairs');
xlabel(sprintf('< 0: %.2f %%, Bino-p: %.2f', out_actual_mean_sf_prop * 100, bino_p_mean));
set(gca, 'yticklabel', [])

subplot(2, 4, 4);
imagesc(out_M_ID,'AlphaData', ~isnan(out_M_ID));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
set(gca, 'xticklabel', [], 'yticklabel', []);

subplot(2, 4, 8);
histogram(out_M_ID, 50)
title('Hypertransform - ID');
ylabel('# of pairs');
xlabel(sprintf('< 0: %.2f %%, Bino-p: %.2f', out_id_prop * 100, bino_p_id));
set(gca, 'yticklabel', [])

%% Create M v.s ID figure
M = out_actual_dists(~isnan(out_actual_dists))';
ID = out_id_dists(~isnan(out_id_dists))';
plot([zeros(size(M)); ones(size(ID))], [M; ID]); hold on;
plot([zeros(size(M)); ones(size(ID))], [M; ID], '.', 'MarkerSize', 10);
xlim([-0.1 1.1])
title(sprintf('Welch’s t-test: %.2f (%.2f %%), Binomial CDF: %.2f %%', t_h, t_p, bino_p));

%% Create Q figures
for p_i = 1:length(Q)
    imagesc([Q{p_i}.left, Q{p_i}.right]);
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
%% Plot example paired_inputs
% hyper_inputs = {Q, Q_norm_ind, Q_norm_concat, Q_norm_sub};
% hyper_types = {'none', 'ind', 'concat', 'sub_mean'};
hyper_inputs = {Q_norm_average_w_inter, Q_norm_average_wo_inter, Q_average_norm_w_inter, Q_average_norm_wo_inter};
hyper_types = {'Norm\_then\_aver (inter)', 'Norm\_then\_aver (no inter)', 'Aver\_then\_norm (inter)', 'Aver\_then\_norm (no inter)'};
for n_i = 1:length(hyper_inputs)
    subplot(5, 4, n_i)
    imagesc([hyper_inputs{n_i}{1}.left, hyper_inputs{n_i}{1}.right]);
    colorbar;
    % set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 40);
    title(hyper_types{n_i});
end

%% Hyperalignment procedure
rng(mean('hyperalignment'));
for nm_i = 1:length(hyper_types)
    data = hyper_inputs{nm_i};
    cfg_pre = [];
    cfg_pre.normalization = 'none';
    [actual_dists_mat, id_dists_mat] = predict_with_L_R(cfg_pre, data);

    n_shuffles = 1000;
    sf_dists_mat  = zeros(length(data), length(data), n_shuffles);

    for i = 1:n_shuffles
        cfg_pre.shuffled = 1;
        [s_actual_dists_mat] = predict_with_L_R(cfg_pre, data);
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
corr_inputs = {Q_xor, Q_same_mu, Q};
corr_types = {'x-or', 'L R ind. (same μ)', 'Real data'};
for n_i = 1:length(corr_inputs)
    data = corr_inputs{n_i};
    mean_coefs = zeros(1, length(data));
    std_coefs = zeros(1, length(data));

    for i = 1:length(data)
        whiten_left = data{i}.left + 0.00001 * rand(size(data{i}.left));
        whiten_right = data{i}.right + 0.00001 * rand(size(data{i}.right));

        cell_coefs = zeros(size(whiten_left, 1), 1);
        for j = 1:size(whiten_left, 1)
            [coef] = corrcoef(whiten_left(j, :), whiten_right(j, :));
            cell_coefs(j) = coef(1, 2);
        end
        mean_coefs(i) = mean(cell_coefs, 'omitnan');
        std_coefs(i) = std(cell_coefs, 'omitnan');
    end

    subplot(2, 3, n_i)
    errorbar(1:length(mean_coefs), mean_coefs, std_coefs);
    xlabel('sessions'); ylabel('corrcoefs')
    title(corr_types{n_i});
end

%% Cell-by-cell correlations across subjects
rng(mean('hyperalignment'));
corr_inputs = {Q_xor, Q_ind, Q_same_mu, Q};
corr_types = {'x-or', 'ind.', 'ind.\\(same $\mu$)', 'data'};

mean_coefs_types = zeros(length(corr_inputs), 1);
% sem_coefs_types = zeros(length(corr_inputs), 1);
sd_coefs_types = zeros(length(corr_inputs), 1);
for n_i = 1:length(corr_inputs)
    data = corr_inputs{n_i};
    sub_ids_start = [1, 5, 10, 12];
    sub_ids_end = [4, 9, 11, 19];
    mean_coefs = zeros(1, length(sub_ids_start));

    for s_i = 1:length(sub_ids_start)
        cell_coefs = [];
        for w_i = sub_ids_start(s_i):sub_ids_end(s_i)
            whiten_left = data{w_i}.left + 0.00001 * rand(size(data{w_i}.left));
            whiten_right = data{w_i}.right + 0.00001 * rand(size(data{w_i}.right));

            for c_i = 1:size(data{w_i}.left, 1)
                [coef] = corrcoef(whiten_left(c_i, :), whiten_right(c_i, :));
                cell_coefs = [cell_coefs, coef(1, 2)];
            end
        end
        mean_coefs(s_i) = mean(cell_coefs, 'omitnan');
    end
    mean_coefs_types(n_i) = mean(mean_coefs);
    % sem_coefs_types(n_i) = std(mean_coefs) / sqrt(length(mean_coefs));
    sd_coefs_types(n_i) = std(mean_coefs);
end

figure; subplot(231);

dx = 0.1;
x = dx * (1:length(corr_inputs));
xpad = 0.05;
h = errorbar(x, mean_coefs_types, sd_coefs_types, 'LineStyle', 'none', 'LineWidth', 2);
set(h, 'Color', 'k');
hold on;
plot(x, mean_coefs_types, '.k', 'MarkerSize', 20);
set(gca, 'TickLabelInterpreter', 'latex');
set(gca, 'XTick', x, 'YTick', [-0.05:0.1:0.3], 'XTickLabel', corr_types, ...
    'XLim', [x(1)-xpad x(end)+xpad], 'YLim', [-0.05 0.3], 'FontSize', 24, ...
    'LineWidth', 1, 'TickDir', 'out');
title('Cell-by-cell correlation coefficients (averaged) across subjects');
box off;
plot([x(1)-xpad x(end)+xpad], [0 0], '--k', 'LineWidth', 1, 'Color', [0.7 0.7 0.7]);

%% Population Vector analysis
corr_inputs = {Q, Q_adr, Q_xor, Q_ind, Q_same_mu};
for n_i = 1:length(corr_inputs)
    data = corr_inputs{n_i};
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
    subplot(2, 3, 1 + n_i)
    imagesc(mean_coefs);
    colorbar;
    this_scale = [-0.25 1]; caxis(this_scale);
    xlabel('L -> R'); ylabel('L -> R');
end

%% Cell-by-cell correlations for all sessions in data, group by significant or not
corr_inputs = {Q_xor, Q_same_mu, Q};
corr_types = {'x-or', 'L R ind. (same μ)', 'Real data'};
for n_i = 1:length(corr_inputs)
    data = corr_inputs{n_i};
    sig_coefs = [];
    insig_coefs = [];

    for i = 1:length(data)
        whiten_left = data{i}.left  + 0.00001 * rand(size(data{i}.left));
        whiten_right = data{i}.right  + 0.00001 * rand(size(data{i}.right));
        for j = 1:size(data{i}.left, 1)
            [coef, p] = corrcoef(whiten_left(j, :), whiten_right(j, :));
            if p(1, 2) < 0.05
                sig_coefs = [sig_coefs, coef(1, 2)];
            else
                insig_coefs = [insig_coefs, coef(1, 2)];
            end
        end
    end

    subplot(1, 3, n_i)
    histogram(sig_coefs, 20);
    hold on;
    histogram(insig_coefs, 20);
    legend('Significant', 'Insignificant');
    title(corr_types{n_i});
end

%% Cell-by-cell for [Source, Predicted, Target]
for source_id = 1:length(Q)
    pair_len = 6;
    target_array = 1:length(Q); target_array(source_id) = [];
    target_ids = datasample(target_array, pair_len, 'Replace', false);

    for t_i = 1:length(target_ids)
        target_id = target_ids(t_i);
        p_target.left = predicted_mat{source_id, target_id}(:, 1:48);
        p_target.right = predicted_mat{source_id, target_id}(:, 49:end);
        paired_inputs = {Q{source_id}, p_target, Q{target_id}};
        paired_titles = {'Source', 'Predicted', 'Target'};

        for p_i = 1:length(paired_inputs)
            p_input = paired_inputs{p_i};
            sig_coefs = [];
            insig_coefs = [];
            for c_i = 1:size(p_input.left, 1)
                [coef, p] = corrcoef(p_input.left(c_i, :), p_input.right(c_i, :));
                if p(1, 2) < 0.05
                    sig_coefs = [sig_coefs, coef(1, 2)];
                else
                    insig_coefs = [insig_coefs, coef(1, 2)];
                end
            end
            subplot(pair_len, 3, 3 * (t_i - 1) + p_i)
            histogram(sig_coefs, 20);
            hold on;
            histogram(insig_coefs, 20);
            title(paired_titles{p_i});
        end
    end
    saveas(gcf, sprintf('source_%d.png', source_id));
    figure;
end

%% Population vectors for [Source, Predicted, Target]
for source_id = 1:length(Q)
    pair_len = 4;
    target_array = 1:length(Q); target_array(source_id) = [];
    target_ids = datasample(target_array, pair_len, 'Replace', false);

    for t_i = 1:length(target_ids)
        target_id = target_ids(t_i);
        Q_source = [Q{source_id}.left, Q{source_id}.right];
        Q_target = [Q{target_id}.left, Q{target_id}.right];
        paired_inputs = {Q_source, predicted_mat{source_id, target_id}, Q_target};
        paired_titles = {'Source', 'Predicted', 'Target'};
        for p_i = 1:length(paired_inputs)
            p_input = paired_inputs{p_i};

            w_len = size(p_input, 2);
            w_coefs = zeros(w_len, w_len);
            for j = 1:w_len
                for k = 1:w_len
                    [coef] = corrcoef(p_input(:, j), p_input(:, k));
                    w_coefs(j, k) = coef(1, 2);
                end
            end

            subplot(pair_len, 3, 3 * (t_i - 1) + p_i)
            imagesc(w_coefs);
            colorbar;
            title(paired_titles{p_i});
            xlabel('L -> R'); ylabel('L -> R');
        end
    end
    saveas(gcf, sprintf('source_%d.png', source_id));
    figure;
end

% Correlation plots for applying hypertransform on simulated data.
%% Cell-by-cell correlation
mean_coefs = zeros(length(sim_data), length(sim_data));
std_coefs = zeros(length(sim_data), length(sim_data));
for i = 1:length(sim_data)
    whiten_left = sim_data{i}.left + 0.001 * rand(size(sim_data{i}.left));
    for j = 1:length(sim_data)
        if ~isnan(out_predicted_data_mat{j, i})
            whiten_right = out_predicted_data_mat{j, i} + 0.001 * rand(size(out_predicted_data_mat{j, i}));
            cell_coefs = zeros(size(whiten_left, 1), 1);
            for k = 1:size(whiten_left, 1)
                [coef] = corrcoef(whiten_left(k, :), whiten_right(k, :));
                cell_coefs(k) = coef(1, 2);
            end
            mean_coefs(j, i) = mean(cell_coefs, 'omitnan');
            std_coefs(j, i) = std(cell_coefs, 'omitnan');
        end
    end
end

errorbar(1:length(mean_coefs), mean(mean_coefs, 1), mean(std_coefs, 1));
xlabel('sessions'); ylabel('coefs')

%% Population Vector Analysis (PVA)
coefs = cell(length(sim_data), length(sim_data));
w_len = size(sim_data{1}.left, 2) * 2;
for i = 1:length(sim_data)
    for c_i = 1:length(sim_data)
        if ~isnan(out_predicted_data_mat{c_i, i})
            w_coefs = zeros(w_len, w_len);
            corr_data = [sim_data{i}.left, out_predicted_data_mat{c_i, i}];
            for j = 1:w_len
                for k = 1:w_len
                    [coef] = corrcoef(corr_data(:, j), corr_data(:, k));
                    w_coefs(j, k) = coef(1, 2);
                end
            end
            coefs{c_i, i} = w_coefs;
        end
    end
end
mean_coefs = mean(cat(3, coefs{:}), 3, 'omitnan');

imagesc(mean_coefs);
colorbar;
xlabel('L -> R'); ylabel('L -> R');
