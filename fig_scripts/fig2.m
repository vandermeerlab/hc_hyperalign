rng(mean('hyperalignment'));
colors = get_hyper_colors();

%% Hyperalignment procedure
% Carey: 1, ADR: 2;
datas = {Q, adr_Q};
for d_i = 1:length(datas)
    data = datas{d_i};
    [actual_dists_mat{d_i}, id_dists_mat{d_i}, sf_dists_mat{d_i}] = predict_with_shuffles([], data, @predict_with_L_R);
    [actual_dists_mat_pca{d_i}, id_dists_mat_pca{d_i}] = predict_with_L_R_pca([], data);
%     [actual_dists_mat_pca{d_i}, id_dists_mat_pca{d_i}, sf_dists_mat_pca{d_i}] = predict_with_shuffles([], data, @predict_with_L_R_pca);
end

%% Source-target figures in Carey
[z_score_m, mean_shuffles_m, proportion_m] = calculate_common_metrics([], actual_dists_mat{1}, ...
    id_dists_mat{1}, sf_dists_mat{1});

titles = {'HT z-score vs. shuffle', 'HT distance - shuffled dist.', 'p(HT dist. > shuffled dist.)'};

cfg_plot = [];
clims = {[-6 6], [-1e4 1e4], [0 1]};

matrix_obj = {z_score_m.out_zscore_mat, mean_shuffles_m.out_actual_mean_sf, proportion_m.out_actual_sf_mat};
for m_i = 1:length(matrix_obj)
    this_ax = subplot(3, 3, m_i);

    cfg_plot.ax = this_ax;
    cfg_plot.clim = clims{m_i};
    cfg_plot.title = titles{m_i};

    plot_matrix(cfg_plot, matrix_obj{m_i});
end
set(gcf, 'Position', [316 185 898 721]);

%% Hypertransform and PCA-only in Carey and ADR
x_limits = {[-6.5, 6.5], [-2.05e4, 2.05e4], [0, 1]}; % two rows, three columns in figure
x_tick = {-6:6, -2e4:2.5e3:2e4, 0:0.2:1};
xtick_labels = {{-6, 6}, {sprintf('-1\\times10^{%d}', 5), sprintf('1\\times10^{%d}', 5)}, {0, 1}};
binsizes = [1, 3.5e3, 0.1]; % for histograms

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist, colors.pca.hist};
cfg_plot.fit_colors = {colors.HT.fit, colors.pca.fit};

for d_i = 1:length(datas) % one row each for Carey, ADR
    cfg_metric = [];
    cfg_metric.use_adr_data = 0;
    if d_i == 2
        cfg_metric.use_adr_data = 1;
    end
    [z_score{d_i}, mean_shuffles{d_i}, proportion{d_i}] = calculate_common_metrics(cfg_metric, actual_dists_mat{d_i}, ...
        id_dists_mat{d_i}, sf_dists_mat{d_i});
%     [z_score_pca{d_i}, mean_shuffles_pca{d_i}, proportion_pca{d_i}] = calculate_common_metrics(cfg_metric, actual_dists_mat_pca{d_i}, ...
%         id_dists_mat_pca{d_i}, sf_dists_mat{d_i});
    
    % Hard to deal with value on the limit, ex: a lot of ones in proportion
    % Workaround: Make them into 0.9999, only for visualization purpose
    keep_idx = ~isnan(proportion{d_i}.out_actual_sf_mat);
    proportion_mat = min(proportion{d_i}.out_actual_sf_mat(keep_idx), 0.9999);
%     proportion_mat_pca = min(proportion_pca{d_i}.out_actual_sf_mat(keep_idx), 0.9999);

    matrix_objs = {{z_score{d_i}.out_zscore_mat}, ...
        {mean_shuffles{d_i}.out_actual_mean_sf}, ...
        {proportion_mat}};

    for m_i = 1:length(matrix_objs) % loop over columns
        this_ax = subplot(3, 3, (3 * d_i) + m_i);
        % p_i = (d_i - 1)*3 + m_i; % plot index to access x_limits etc defined above
        matrix_obj = matrix_objs{m_i};

        cfg_plot.xlim = x_limits{m_i};
        cfg_plot.xtick = x_tick{m_i};
        cfg_plot.xtick_label = xtick_labels{m_i};
        cfg_plot.binsize = binsizes(m_i);
        cfg_plot.ax = this_ax;
        cfg_plot.insert_zero = 1; % plot zero xtick
        cfg_plot.plot_vert_zero = 1;
        cfg_plot.fit = 'vline'; % 'gauss', 'kernel', 'vline' or 'none (no fit)
        if m_i == 3
            cfg_plot.fit = 'none';
            cfg_plot.insert_zero = 0;
            cfg_plot.plot_vert_zero = 0;
        end

        plot_hist2(cfg_plot, matrix_obj); % ht, then pca

    end
end

%% Inset
x_limits = {[0, 2*1e5], [0, 1e5]};
x_tick = {0:20000:2*1e5, 0:10000:1e5};
xtick_labels = {{0, sprintf('2\\times10^{%d}', 5)}, {0, sprintf('1\\times10^{%d}', 5)}};
binsizes = [30000, 15000]; % for histograms

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist, colors.pca.hist};
cfg_plot.fit_colors = {colors.HT.fit, colors.pca.fit};
bino_ps = zeros(length(datas), 1);
signrank_ps = zeros(length(datas), 1);

for d_i = 1:length(datas)
    cfg_metric = [];
    cfg_metric.use_adr_data = 0;
    if d_i == 2
        cfg_metric.use_adr_data = 1;
    end
    
    out_actual_dists = set_withsubj_nan(cfg_metric, actual_dists_mat{d_i});
    out_actual_dists_pca = set_withsubj_nan(cfg_metric, actual_dists_mat_pca{d_i});
    
    matrix_obj = {out_actual_dists, out_actual_dists_pca};
    bino_ps(d_i) = calculate_bino_p(sum(sum(out_actual_dists <= out_actual_dists_pca)), sum(sum(~isnan(out_actual_dists))), 0.5);;
    signrank_ps(d_i) = signrank(matrix_obj{1}(:),  matrix_obj{2}(:));
    this_ax = subplot(2, 1, d_i);

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

set(gcf, 'Position', [316 297 353 609]);

%% Stats of HT vs. PCA-only

%% Z-score of HT vs PCA-only in Carey and ADR
% {1: Carey, 2: ADR}
data_idx = 2;
z_score_ht_less_pca = sum(sum(z_score{data_idx}.out_zscore_mat <= z_score_pca{data_idx}.out_zscore_mat))
pair_count = sum(sum(~isnan(z_score{data_idx}.out_zscore_mat)))
prop_ht_less_pca = z_score_ht_less_pca / pair_count
calculate_bino_p(z_score_ht_less_pca, pair_count, 0.5)

%% Mean of HT vs PCA-only in Carey and ADR
% {1: Carey, 2: ADR}
data_idx = 2;
mean_ht_less_pca = sum(sum(mean_shuffles{data_idx}.out_actual_mean_sf <= mean_shuffles_pca{data_idx}.out_actual_mean_sf))
pair_count = sum(sum(~isnan(mean_shuffles{data_idx}.out_actual_mean_sf)))
prop_ht_less_pca = mean_ht_less_pca / pair_count
calculate_bino_p(mean_ht_less_pca, pair_count, 0.5)
