%%
rng(mean('hyperalignment'));
colors = get_hyper_colors();
sub_ids = get_sub_ids_start_end();

datas = {Q, TC, Q_norm_l2, TC_norm_l2, Q_norm_Z, TC_norm_Z};
%% Example inputs
n_units = 30;
% Use indices in Q in case index chosen from Q does not exist in
% Q_int_rm.
% ex_idx = datasample(1:length(Q{1}.left), n_units, 'Replace', false);
colorbar_limits = {[0, 50], [0, 50], [0, 1], [0, 1], [-2, 6], [-2, 6]};
for d_i = 1:length(datas)
    subplot(3, 4, (2*(d_i-1) + 1))
    imagesc([datas{d_i}{1}.left(1:n_units, :), datas{d_i}{1}.right(1:n_units, :)]);
    colorbar;
    caxis(colorbar_limits{d_i});
    set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 12);
    ylabel('neuron');
end

set(gcf, 'Position', [67 73 1784 898]);

%% Hyperalignment procedure
for d_i = 1:length(datas)
    data = datas{d_i};
    [actual_dists_mat{d_i}, id_dists_mat{d_i}, sf_dists_mat{d_i}] = predict_with_shuffles([], data, @predict_with_L_R);
end

%% HT prediction in various normalization.
x_limits = [-6.5, 6.5];
x_tick = -6:6;
binsizes = [1];

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist};
cfg_plot.fit_colors = {colors.HT.fit};

for d_i = 1:length(datas)
    [z_score{d_i}] = calculate_common_metrics([], actual_dists_mat{d_i}, ...
        id_dists_mat{d_i}, sf_dists_mat{d_i});

    matrix_objs = {{z_score{d_i}.out_zscore_mat}};
    for m_i = 1:length(matrix_objs)
        this_ax = subplot(3, 4, (2*(d_i-1) + 2));
        matrix_obj = matrix_objs{m_i};

        cfg_plot.xlim = x_limits;
        cfg_plot.xtick = x_tick;
        cfg_plot.binsize = binsizes;
        cfg_plot.ax = this_ax;
        cfg_plot.insert_zero = 1; % plot zero xtick
        cfg_plot.fit = 'vline'; % 'gauss', 'kernel', 'vline' or 'none (no fit)

        plot_hist2(cfg_plot, matrix_obj);
        ylabel('count')

    end
end

%% PCA-only procedure
for d_i = 1:length(datas)
    data = datas{d_i};
    [actual_dists_mat_pca{d_i}] = predict_with_L_R_pca([], data);
end

%% HT vs. PCA-only in various normalization.
x_limits = {[0, 2*1e5], [0, 2*1e5], [0, 100], [0, 100], [0, 5000], [0, 5000]};
x_tick = {0:20000:2*1e5, 0:20000:2*1e5, 0:10:100, 0:10:100, 0:500:5000, 0:500:5000};
xtick_labels = {{0, sprintf('2\\times10^{%d}', 5)}, {0, sprintf('1\\times10^{%d}', 5)}, ...
    {0, 100}, {0, 100}, {0, 5000}, {0, 5000}};
binsizes = [30000, 30000, 15, 15, 750, 750]; % for histograms

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
    
    out_actual_dists = set_withsubj_nan(cfg_metric, actual_dists_mat{d_i});
    out_actual_dists_pca = set_withsubj_nan(cfg_metric, actual_dists_mat_pca{d_i});
    diff_HT_PCA = out_actual_dists - out_actual_dists_pca;
    pair_count = sum(sum(~isnan(diff_HT_PCA)));
    
    matrix_obj = {out_actual_dists, out_actual_dists_pca};
    bino_ps(d_i) = calculate_bino_p(sum(sum(out_actual_dists <= out_actual_dists_pca)), sum(sum(~isnan(out_actual_dists))), 0.5);;
    signrank_ps(d_i) = signrank(matrix_obj{1}(:),  matrix_obj{2}(:));
    prop_HT_PCA(d_i) = sum(sum(diff_HT_PCA < 0)) / pair_count;
    mean_diff_HT_PCA(d_i) = nanmean(diff_HT_PCA(:));
    sem_diff_HT_PCA(d_i) = nanstd(diff_HT_PCA(:)) / sqrt(4 * 3);
    
    this_ax = subplot(3, 2, d_i);

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

set(gcf, 'Position', [680 195 722 783]);