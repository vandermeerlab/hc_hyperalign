rng(mean('hyperalignment'));
colors = get_hyper_colors();

%% Hyperalignment procedure
% Carey: 1, ADR: 2;
datas = {Q, adr_Q};
for d_i = 1:length(datas)
    data = datas{d_i};
    % Figure 7 uses 'shift', otherwise 'row' shuffle is default.
    cfg_shuffle.shuffle_method = 'shift';
    [actual_dists_mat{d_i}, id_dists_mat{d_i}, sf_dists_mat{d_i}] = predict_with_shuffles(cfg_shuffle, data, @predict_with_L_R);
    [actual_dists_mat_pca{d_i}, id_dists_mat_pca{d_i}] = predict_with_L_R_pca([], data);
end

%% Use the preserved half as control and compare to ground truth
datas = {Q_split, adr_Q_split};
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

%% Calculate metrics
for d_i = 1:length(datas)
    cfg_metric = [];
    cfg_metric.use_adr_data = 0;
    if d_i == 2
        cfg_metric.use_adr_data = 1;
    end

    [z_score{d_i}, mean_shuffles{d_i}, proportion{d_i}] = calculate_common_metrics(cfg_metric, actual_dists_mat{d_i}, ...
        id_dists_mat{d_i}, sf_dists_mat{d_i});
    [HT_PCA{d_i}] = calculate_HT_PCA_metrics(cfg_metric, actual_dists_mat{d_i}, ...
        actual_dists_mat_pca{d_i}, actual_dists_mat_sp{d_i});
end

%% Source-target figures in Carey
titles = {'HT z-score vs. shuffle', 'HT distance - shuffled dist.', 'p(HT dist. > shuffled dist.)'};

cfg_plot = [];
clims = {[-6 6], [-1e2 1e2], [0 1]};
if strcmp(cfg_shuffle.shuffle_method, 'shift')
    clims{2} = [-1e2 1e2];
end

matrix_obj = {z_score{1}.out_zscore_mat, mean_shuffles{1}.out_actual_mean_sf, proportion{1}.out_actual_sf_mat};
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
xtick_labels = {{-6, 6}, {-2000, 2000}, {0, 1}};
binsizes = [1, 3e2, 0.1];

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist};
cfg_plot.fit_colors = {colors.HT.fit};

for d_i = 1:length(datas) % one row each for Carey, ADR
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
            xtick_labels{2} = {-200, 200};
            binsizes(2) = 30;
        else
            x_limits{2} = [-5.05e2, 5.05e2];
            x_tick{2} = -5e2:125:5e2;
            xtick_labels{2} = {-500, 500};
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
        if strcmp(cfg_shuffle.shuffle_method, 'row')
            if m_i == 2
                hold on;
                out_lower_m_sf_error{d_i} = HT_PCA{d_i}.out_actual_dists_sp - mean(sf_dists_mat{d_i}, 3);
                lower_bound_m = nanmedian(out_lower_m_sf_error{d_i}(:));
                vh_lower = vline(lower_bound_m, '-'); set(vh_lower, 'Color', 'r');
            end
        end
    end
end

set(gcf, 'Position', [316 185 898 721]);

%% HT vs. PCA-only in Carey and ADR
x_limits = {[0, 3*1e3], [0, 1e3]};
x_tick = {0:300:3*1e3, 0:100:1e3};
xtick_labels = {{0, 3000}, {0, 1000}};
binsizes = [450, 150]; % for histograms

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist, colors.pca.hist};
cfg_plot.fit_colors = {colors.HT.fit, colors.pca.fit};

for d_i = 1:length(datas)
    data = datas{d_i};
    % s_raw_errors{d_i} = set_withsubj_nan(cfg_metric, mean(sf_dists_mat{d_i}, 3));

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
    vh_lower = vline(lower_bound_m, '-'); set(vh_lower, 'Color', 'r');
    % hold on;
    % upper_bound_m = nanmedian(s_raw_errors{d_i}(:));
    % vh_upper = vline(upper_bound_m, '-'); set(vh_upper, 'Color', 'k');
end

set(gcf, 'Position', [316 297 353 609]);
