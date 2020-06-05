rng(mean('hyperalignment'));
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
    id_dists_mat_pca, sf_dists_mat);

%% Withholding (Q) and Hypertransform and PCA-only (TC) in Carey
datas = {Q, TC};

x_limits = {[-6.5, 6.5], [-5.05e5, 5.05e5], [0, 1]}; % two rows, three columns in figure
x_tick = {-6:6,-5e5:1.25e5:5e5, 0:0.2:1};
xtick_labels = {{-6, 6}, {sprintf('-5\\times10^{%d}', 5), sprintf('5\\times10^{%d}', 5)}, {0, 1}};
binsizes = [1, 7.5e4, 0.1]; % for histograms

% Hard to deal with value on the limit, ex: a lot of ones in proportion
% Workaround: Make them into 0.9999, only for visualization purpose
keep_idx = ~isnan(proportion.out_actual_sf_mat);
proportion_mat_wh = min(proportion_wh.out_actual_sf_mat(keep_idx), 0.9999);
proportion_mat = min(proportion.out_actual_sf_mat(keep_idx), 0.9999);


all_hist_colors = {{colors.wh.hist}, {colors.HT.hist}};
all_fit_colors = {{colors.wh.fit}, {colors.HT.hist}};
all_matrix_objs = {{{z_score_wh.out_zscore_mat}, ...
        {mean_shuffles_wh.out_actual_mean_sf}, ...
        {proportion_mat_wh}}, ...
        {{z_score.out_zscore_mat}, ...
        {mean_shuffles.out_actual_mean_sf}, ...
        {proportion_mat}}};


for d_i = 1:length(datas) % one row each for Withholding (Carey Q), HT and PCA (Caret TC)
    cfg_plot = [];
    cfg_plot.hist_colors = all_hist_colors{d_i};
    cfg_plot.fit_colors = all_fit_colors{d_i};

    matrix_objs = all_matrix_objs{d_i};

    for m_i = 1:length(matrix_objs) % loop over columns
        p_i = (d_i - 1) * 3 + m_i; % plot index to access x_limits etc defined above
        this_ax = subplot(2, 3, p_i);
        matrix_obj = matrix_objs{m_i};

        cfg_plot.xlim = x_limits{m_i};
        cfg_plot.xtick = x_tick{m_i};
        cfg_plot.xtick_label = xtick_labels{m_i};
        cfg_plot.binsize = binsizes(m_i);
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

%% HT vs. PCA-only in Carey TC
datas = {TC};

x_limits = {[0, 2*1e5]};
x_tick = {0:20000:2*1e5};
xtick_labels = {{0, sprintf('2\\times10^{%d}', 5)}};
binsizes = [30000]; % for histograms

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist, colors.pca.hist};
cfg_plot.fit_colors = {colors.HT.fit, colors.pca.fit};

bino_ps = zeros(length(datas), 1);
signrank_ps = zeros(length(datas), 1);
prop_HT_PCA = zeros(length(datas), 1);
mean_diff_HT_PCA = zeros(length(datas), 1);
sem_diff_HT_PCA = zeros(length(datas), 1);

for d_i = 1:length(datas)
    cfg_metric = [];
    cfg_metric.use_adr_data = 0;
    
    out_actual_dists = set_withsubj_nan(cfg_metric, actual_dists_mat);
    out_actual_dists_pca = set_withsubj_nan(cfg_metric, actual_dists_mat_pca);
    diff_HT_PCA = out_actual_dists - out_actual_dists_pca;
    pair_count = sum(sum(~isnan(diff_HT_PCA)));
    
    matrix_obj = {out_actual_dists, out_actual_dists_pca};
    bino_ps(d_i) = calculate_bino_p(sum(sum(out_actual_dists <= out_actual_dists_pca)), sum(sum(~isnan(out_actual_dists))), 0.5);;
    signrank_ps(d_i) = signrank(matrix_obj{1}(:),  matrix_obj{2}(:));
    prop_HT_PCA(d_i) = sum(sum(diff_HT_PCA < 0)) / pair_count;
    mean_diff_HT_PCA(d_i) = nanmean(diff_HT_PCA(:));
    sem_diff_HT_PCA(d_i) = nanstd(diff_HT_PCA(:)) / sqrt(4 * 3);
    
    this_ax = [];

    cfg_plot.xlim = x_limits{d_i};
    cfg_plot.xtick = x_tick{d_i};
    cfg_plot.xtick_label = xtick_labels{d_i};
    cfg_plot.binsize = binsizes(d_i);
    cfg_plot.ax = this_ax;
    cfg_plot.insert_zero = 0; % plot zero xtick
    cfg_plot.fit = 'vline'; % 'gauss', 'kernel', 'vline' or 'none (no fit)
    cfg_plot.plot_vert_zero = 0; % plot vertical dashed line at 0

    plot_hist2(cfg_plot, matrix_obj); % ht, then pca
end

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
