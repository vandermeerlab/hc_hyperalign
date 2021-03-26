rng(mean('hyperalignment'));
colors = get_hyper_colors();

%% Hyperalignment procedure
% Carey: 1, ADR: 2;
datas = {Q, adr_Q};
for d_i = 1:length(datas)
    data = datas{d_i};
    % Figure S10 uses 'shift', otherwise 'row' shuffle is default.
    cfg_shuffle.shuffle_method = 'row';
    [actual_dists_mat{d_i}, id_dists_mat{d_i}, sf_dists_mat{d_i}] = predict_with_shuffles(cfg_shuffle, data, @predict_with_L_R);
    [actual_dists_mat_pca{d_i}, id_dists_mat_pca{d_i}] = predict_with_L_R_pca([], data);
end

%% Source-target figures in Carey
set(gcf, 'Position', [316 185 898 721]);

[z_score_m, mean_shuffles_m, proportion_m] = calculate_common_metrics([], actual_dists_mat{1}, ...
    id_dists_mat{1}, sf_dists_mat{1});

titles = {'HT z-score vs. shuffle', 'HT distance - shuffled dist.', 'p(HT dist. > shuffled dist.)'};

cfg_plot = [];
clims = {[-6 6], [-1e2 1e2], [0 1]};
if strcmp(cfg_shuffle.shuffle_method, 'shift')
    clims{2} = [-1e2 1e2];
end

matrix_obj = {z_score_m.out_zscore_mat, mean_shuffles_m.out_actual_mean_sf, proportion_m.out_actual_sf_mat};
for m_i = 1:length(matrix_obj)
    this_ax = subplot(3, 3, m_i);

    cfg_plot.ax = this_ax;
    cfg_plot.clim = clims{m_i};
    cfg_plot.title = titles{m_i};

    plot_matrix(cfg_plot, matrix_obj{m_i});
end

%% Hypertransform in Carey and ADR
x_limits = {[-6.5, 6.5], [-2.05e3, 2.05e3], [0, 1]};
x_tick = {-6:6, -2e3:5e2:2e3, 0:0.2:1};
xtick_labels = {{-6, 6}, {sprintf('-2\\times10^{%d}', 3), sprintf('2\\times10^{%d}', 3)}, {0, 1}};
binsizes = [1, 3e2, 0.1];

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist};
cfg_plot.fit_colors = {colors.HT.fit};

for d_i = 1:length(datas) % one row each for Carey, ADR
    cfg_metric = [];
    cfg_metric.use_adr_data = 0;
    if d_i == 2
        cfg_metric.use_adr_data = 1;
    end
    [z_score{d_i}, mean_shuffles{d_i}, proportion{d_i}] = calculate_common_metrics(cfg_metric, actual_dists_mat{d_i}, ...
        id_dists_mat{d_i}, sf_dists_mat{d_i});
   
    % Hard to deal with value on the limit, ex: a lot of ones in proportion
    % Workaround: Make them into 0.9999, only for visualization purpose
    keep_idx = ~isnan(proportion{d_i}.out_actual_sf_mat);
    proportion_mat = min(proportion{d_i}.out_actual_sf_mat(keep_idx), 0.9999);
    
    matrix_objs = {{z_score{d_i}.out_zscore_mat}, ...
        {mean_shuffles{d_i}.out_actual_mean_sf}, ...
        {proportion_mat}};
    
    if strcmp(cfg_shuffle.shuffle_method, 'shift')
        if d_i == 1
            x_limits{2} = [-2.05e2, 2.05e2];
            x_tick{2} = -2e2:50:2e2;
            xtick_labels{2} = {sprintf('-2\\times10^{%d}', 2), sprintf('2\\times10^{%d}', 2)};
            binsizes(2) = 30;
        else
            x_limits{2} = [-5.05e2, 5.05e2];
            x_tick{2} = -5e2:125:5e2;
            xtick_labels{2} = {sprintf('-5\\times10^{%d}', 2), sprintf('5\\times10^{%d}', 2)};
            binsizes(2) = 75;
        end
    end

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

%% Use the preserved half as control and compare to ground truth
datas_split = {Q_split, adr_Q_split};
for d_i = 1:length(datas)
    data = datas{d_i};
    for sr_i = 1:length(data)
        for tar_i = 1:length(data)
            ground_truth = data{tar_i}.right;
            if sr_i ~= tar_i
                actual_dist = calculate_dist('all', data{tar_i}.right_half, ground_truth) / size(ground_truth, 1);
                actual_dists_mat_sp{d_i}(sr_i, tar_i) = actual_dist;
            else
                actual_dists_mat_sp{d_i}(sr_i, tar_i) = NaN;
            end
        end
    end
end

%% HT vs. PCA-only in Carey and ADR
x_limits = {[0, 3*1e3], [0, 1e3]};
x_tick = {0:300:3*1e3, 0:100:1e3};
xtick_labels = {{0, sprintf('3\\times10^{%d}', 3)}, {0, sprintf('1\\times10^{%d}', 3)}};
binsizes = [450, 150]; % for histograms

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist, colors.pca.hist};
cfg_plot.fit_colors = {colors.HT.fit, colors.pca.fit};

for d_i = 1:length(datas)
    data = datas{d_i};
    
    cfg_metric = [];
    cfg_metric.use_adr_data = 0;
    if d_i == 2
        cfg_metric.use_adr_data = 1;
    end
    
    [HT_PCA{d_i}] = calculate_HT_PCA_metrics(cfg_metric, actual_dists_mat{d_i}, ...
        actual_dists_mat_pca{d_i}, actual_dists_mat_sp{d_i});
    
    matrix_obj = {HT_PCA{d_i}.out_actual_dists, HT_PCA{d_i}.out_actual_dists_pca};
    
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
    hold on;
    lower_bound_m = nanmedian(HT_PCA{d_i}.out_actual_dists_sp(:));
    vh = vline(lower_bound_m, '-'); set(vh, 'Color', 'r');
end
set(gcf, 'Position', [316 297 353 609]);

%% PCA-only in Carey and ADR
x_limits = {[-6.5, 6.5], [-1.05e5, 1.05e5], [0, 1]}; % two rows, three columns in figure
x_tick = {-6:6, -1e5:2.5e4:1e5, 0:0.2:1};
xtick_labels = {{-6, 6}, {sprintf('-1\\times10^{%d}', 5), sprintf('1\\times10^{%d}', 5)}, {0, 1}};
binsizes = [1, 1.5e4, 0.1]; % for histograms

cfg_plot = [];
cfg_plot.hist_colors = {colors.pca.hist};
cfg_plot.fit_colors = {colors.pca.fit};

for d_i = 1:length(datas) % one row each for Carey, ADR
    cfg_metric = [];
    cfg_metric.use_adr_data = 0;
    if d_i == 2
        cfg_metric.use_adr_data = 1;
    end
    [z_score_pca{d_i}, mean_shuffles_pca{d_i}, proportion_pca{d_i}] = calculate_common_metrics(cfg_metric, actual_dists_mat_pca{d_i}, ...
        id_dists_mat_pca{d_i}, sf_dists_mat{d_i});
    
    % Hard to deal with value on the limit, ex: a lot of ones in proportion
    % Workaround: Make them into 0.9999, only for visualization purpose
    keep_idx = ~isnan(proportion{d_i}.out_actual_sf_mat);
    proportion_mat_pca = min(proportion_pca{d_i}.out_actual_sf_mat(keep_idx), 0.9999);

    matrix_objs = {{z_score_pca{d_i}.out_zscore_mat}, ...
        {mean_shuffles_pca{d_i}.out_actual_mean_sf}, ...
        {proportion_mat_pca}};

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

%% Stats of HT vs. PCA-only

%% HT vs PCA-only in Carey and ADR
% {1: Carey, 2: ADR}
data_idx = 2;
z_score_ht_less_pca = sum(sum(z_score{data_idx}.out_zscore_mat <= z_score_pca{data_idx}.out_zscore_mat))
pair_count = sum(sum(~isnan(z_score{data_idx}.out_zscore_mat)))
prop_ht_less_pca = z_score_ht_less_pca / pair_count
calculate_bino_p(z_score_ht_less_pca, pair_count, 0.5)
