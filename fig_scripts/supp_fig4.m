rng(mean('hyperalignment'));
colors = get_hyper_colors();

%% Hyperalignment procedure
datas = {Q_split, Q_one, TC_split};
predict_funcs = {@predict_with_L_R_withhold, @predict_with_L_R_withhold_only_left, @predict_with_L_R};
predict_pca_funcs = {@predict_with_L_R_withhold_pca, @predict_with_L_R_withhold_pca, @predict_with_L_R_pca};

for d_i = 1:length(datas)
    data = datas{d_i};
    if d_i == 1
        cfg_predict.target_align = 'one';
    elseif d_i == 2
        cfg_predict.target_align = 'padding';
    end
    [actual_dists_mat{d_i}, id_dists_mat{d_i}, sf_dists_mat{d_i}] = predict_with_shuffles(cfg_predict, data, predict_funcs{d_i});
    [actual_dists_mat_pca{d_i}, id_dists_mat_pca{d_i}] = predict_pca_funcs{d_i}(cfg_predict, data);
end

%% Calculate metrics
for d_i = 1:length(datas)
    cfg_metric = [];
    cfg_metric.use_adr_data = 0;
    [z_score{d_i}, mean_shuffles{d_i}, proportion{d_i}] = calculate_common_metrics(cfg_metric, actual_dists_mat{d_i}, ...
        id_dists_mat{d_i}, sf_dists_mat{d_i});
end

%% Withholding (Q) and Hypertransform (TC) in Carey
x_limits = {[-6.5, 6.5], [-5.05e3, 5.05e3], [0, 1]}; % two rows, three columns in figure
x_tick = {-6:6,-5e3:1.25e3:5e3, 0:0.2:1};
xtick_labels = {{-6, 6}, {-5000, 5000}, {0, 1}};
binsizes = [1, 7.5e2, 0.1]; % for histograms

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist};
cfg_plot.fit_colors = {colors.HT.fit};

for d_i = 1:length(datas) % one row each for Withholding (Carey Q), HT and PCA (Caret TC)
    
    % Hard to deal with value on the limit, ex: a lot of ones in proportion
    % Workaround: Make them into 0.9999, only for visualization purpose
    keep_idx = ~isnan(proportion{d_i}.out_actual_sf_mat);
    proportion_mat = min(proportion{d_i}.out_actual_sf_mat(keep_idx), 0.9999);
    
    matrix_objs = {{z_score{d_i}.out_zscore_mat}, ...
        {mean_shuffles{d_i}.out_actual_mean_sf}, ...
        {proportion_mat}};
    
    for m_i = 1:length(matrix_objs) % loop over columns
        p_i = (d_i - 1) * 3 + m_i; % plot index to access x_limits etc defined above
        this_ax = subplot(3, 3, p_i);
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

set(gcf, 'Position', [316 185 898 721]);

%% Use the preserved half as control and compare to ground truth
datas = {Q_split, Q_one, TC_split};
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

%% HT vs. PCA-only in Carey Withholding and TC
datas = {Q_split, Q_one, TC_split};

x_limits = {[0, 6000], [0, 5000], [0, 2000]};
x_tick = {0:600:6000, 0:500:5000, 0:200:2000};
xtick_labels = {{0, 6000}, {0, 5000}, {0, 2000}};
binsizes = [600, 500, 200]; % for histograms

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist, colors.pca.hist};
cfg_plot.fit_colors = {colors.HT.fit, colors.pca.fit};

for d_i = 1:length(datas)
    cfg_metric = [];
    cfg_metric.use_adr_data = 0;
    
    [HT_PCA{d_i}] = calculate_HT_PCA_metrics(cfg_metric, actual_dists_mat{d_i}, ...
        actual_dists_mat_pca{d_i}, actual_dists_mat_sp{d_i});
    s_raw_errors{d_i} = set_withsubj_nan(cfg_metric, mean(sf_dists_mat{d_i}, 3));
    
    matrix_obj = {HT_PCA{d_i}.out_actual_dists, HT_PCA{d_i}.out_actual_dists_pca};
    
    this_ax = subplot(3, 1, d_i);

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
    hold on;
    upper_bound_m = nanmedian(s_raw_errors{d_i}(:));
    vh_upper = vline(upper_bound_m, '-'); set(vh_upper, 'Color', 'k');
end

set(gcf, 'Position', [316 124 377 782]);