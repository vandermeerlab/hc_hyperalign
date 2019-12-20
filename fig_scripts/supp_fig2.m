colors = get_hyper_colors();

%% Hyperalignment procedure
data = Q;
[actual_dists_mat_wh, id_dists_mat_wh, sf_dists_mat_wh] = predict_with_shuffles([], data, @predict_with_L_R_withhold);

data = TC;
[actual_dists_mat, id_dists_mat, sf_dists_mat] = predict_with_shuffles([], data, @predict_with_L_R);
[actual_dists_mat_pca, id_dists_mat_pca, sf_dists_mat_pca] = predict_with_shuffles([], data, @predict_with_L_R_pca);

%% Calculate metrics
[z_score_wh, mean_shuffles_wh, proportion_wh] = calculate_common_metrics([], actual_dists_mat_wh, ...
    id_dists_mat_wh, sf_dists_mat_wh);

[z_score, mean_shuffles, proportion] = calculate_common_metrics([], actual_dists_mat, ...
    id_dists_mat, sf_dists_mat);
[z_score_pca, mean_shuffles_pca, proportion_pca] = calculate_common_metrics([], actual_dists_mat_pca, ...
    id_dists_mat_pca, sf_dists_mat_pca);

%% Withholding (Q) and Hypertransform and PCA-only (TC) in Carey
datas = {Q, TC};

x_limits = {[-6.5, 6.5], [-1050, 1050], [0, 1], [-6.5, 6.5], [-5.05e5, 5.05e5], [0, 1]}; % two rows, three columns in figure
x_tick = {-6:6, -1000:250:1000, 0:0.2:1, -6:6, -5e5:1.25e5:5e5, 0:0.2:1};
binsizes = [1, 150, 0.1, 1, 7.5e4, 0.1]; % for histograms

all_hist_colors = {{colors.wh.hist}, {colors.HT.hist, colors.pca.hist}};
all_fit_colors = {{colors.wh.fit}, {colors.HT.hist, colors.pca.hist}};
all_matrix_objs = {{{z_score_wh.out_zscore_mat}, ...
        {mean_shuffles_wh.out_actual_mean_sf}, ...
        {proportion_wh.out_actual_sf_mat}}, ...
        {{z_score.out_zscore_mat, z_score_pca.out_zscore_mat}, ...
        {mean_shuffles.out_actual_mean_sf, mean_shuffles_pca.out_actual_mean_sf}, ...
        {proportion.out_actual_sf_mat, proportion_pca.out_actual_sf_mat}}};


for d_i = 1:length(datas) % one row each for Withholding (Carey Q), HT and PCA (Caret TC)
    cfg_plot = [];
    cfg_plot.hist_colors = all_hist_colors{d_i};
    cfg_plot.fit_colors = all_fit_colors{d_i};

    matrix_objs = all_matrix_objs{d_i};

    for m_i = 1:length(matrix_objs) % loop over columns
        p_i = (d_i - 1) * 3 + m_i; % plot index to access x_limits etc defined above
        this_ax = subplot(2, 3, p_i);
        matrix_obj = matrix_objs{m_i};
        
        cfg_plot.xlim = x_limits{p_i};
        cfg_plot.xtick = x_tick{p_i};
        cfg_plot.binsize = binsizes(p_i);
        cfg_plot.ax = this_ax;
        cfg_plot.insert_zero = 1; % plot zero xtick
        cfg_plot.fit = 'vline'; % 'gauss', 'kernel', 'vline' or 'none (no fit)
        if m_i == 3
            cfg_plot.fit = 'none';
            cfg_plot.insert_zero = 0;
            cfg_plot.plot_vert_zero = 0;
        end

        plot_hist2(cfg_plot, matrix_obj); % ht, then pca
    end
end

set(gcf, 'Position', [306 209 1255 746]);

%% Stats of HT vs. PCA-only
% Z-score of HT vs PCA-only in Carey TC
calculate_bino_p(sum(sum(z_score.out_zscore_mat <= z_score_pca.out_zscore_mat)), sum(sum(~isnan(z_score.out_zscore_mat))), 0.5)
% Mean of HT vs PCA-only in Carey TC
calculate_bino_p(sum(sum(mean_shuffles.out_actual_mean_sf <= mean_shuffles_pca.out_actual_mean_sf)), sum(sum(~isnan(mean_shuffles.out_actual_mean_sf))), 0.5)
%% Calculate errors across locations/time
cfg_pre = [];
cfg_pre.dist_dim = 1;
[actual_dists_mat_err, id_dists_mat_err] = predict_with_L_R(cfg_pre, Q);

cfg.use_adr_data = 0;
out_dists = set_withsubj_nan(cfg, actual_dists_mat_err);
out_keep_idx = cellfun(@(C) any(~isnan(C(:))), out_dists);
out_dists = out_dists(out_keep_idx);
out_dists = cell2mat(out_dists);

% Normalize within session to prevent average dominated by high errors
norm_out_dists = zscore(out_dists, 0, 2);
mean_across_w = mean(norm_out_dists, 1);
std_across_w = std(norm_out_dists, 1);

subplot(2, 1, 1);

dy = 1;
x = 1:length(mean_across_w);
xpad = 1;
ylim = [-2, 2];

h = shadedErrorBar(x, mean_across_w, std_across_w);
set(h.mainLine, 'LineWidth', 1);
hold on;
set(gca, 'XTick', [], 'YTick', [ylim(1):dy:ylim(2)], 'XLim', [x(1) x(end)], ...
    'YLim', [ylim(1) ylim(2)], 'FontSize', 12, 'LineWidth', 1, 'TickDir', 'out');
box off;
xlabel('Time'); ylabel('Z-score')

set(gcf, 'Position', [560 121 531 827]);

%% Variance explained as a function of number of PCs
num_pcs = 20;
cum_vars = zeros(length(Q), num_pcs);

for q_i = 1:length(Q)
    % Concatenate Q matrix across left and right trials and perform PCA on it.
    pca_input = [Q{q_i}.left, Q{q_i}.right];
    pca_mean = mean(pca_input, 2);
    pca_input = pca_input - pca_mean;
    [~, ~, ~, ~, explained, ~] = pca(pca_input);
    cum_vars(q_i, :) = cumsum(explained(1:num_pcs));
end

mean_var_pcs = mean(cum_vars, 1);
std_var_pcs = std(cum_vars, 1);

subplot(2, 1, 2);
x = 1:num_pcs;
h = errorbar(x, mean_var_pcs, std_var_pcs, 'LineStyle', '-', 'LineWidth', 1);
hold on;
plot(x, mean_var_pcs, '.', 'MarkerSize', 15, 'Color', [0 0.4470 0.7410]);
set(gca, 'FontSize', 12, 'LineWidth', 1, 'TickDir', 'out');
xlabel('Number of PCs'); ylabel('Explained Variance (%)')
box off;
