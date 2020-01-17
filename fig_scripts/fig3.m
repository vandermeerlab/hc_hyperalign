rng(mean('hyperalignment'));
colors = get_hyper_colors();
sub_ids = get_sub_ids_start_end();

% Carey: 1, ADR: 2;
datas = {Q, adr_Q};
themes = {'Carey', 'ADR'};

%% Hyperalignment procedure
for d_i = 1:length(datas)
    data = datas{d_i};
    [actual_dists_mat{d_i}, id_dists_mat{d_i}, sf_dists_mat{d_i}] = predict_with_shuffles([], data, @predict_with_L_R);
end

%% ID prediction in Carey and ADR
x_limits = {[0, 600], [0, 300]}; % two rows, three columns in figure
x_tick = {0:100:600, 0:50:300};
binsizes = [50, 25]; % for histograms

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist, colors.ID.hist};
cfg_plot.fit_colors = {colors.HT.fit, colors.ID.fit};
bino_ps = zeros(length(datas), 1);
signrank_ps = zeros(length(datas), 1);

for d_i = 1:length(datas)
    cfg_metric = [];
    cfg_metric.use_adr_data = 0;
    if d_i == 2
        cfg_metric.use_adr_data = 1;
    end
    [~, ~, ~, M_ID{d_i}] = calculate_common_metrics(cfg_metric, actual_dists_mat{d_i}, ...
        id_dists_mat{d_i}, sf_dists_mat{d_i});

    matrix_obj = {M_ID{d_i}.out_actual_dists, M_ID{d_i}.out_id_dists};
    bino_ps(d_i) = M_ID{d_i}.bino_p_id;
    signrank_ps(d_i) = signrank(matrix_obj{1}(:),  matrix_obj{2}(:));
    this_ax = subplot(2, 3, d_i);

    cfg_plot.xlim = x_limits{d_i};
    cfg_plot.xtick = x_tick{d_i};
    cfg_plot.binsize = binsizes(d_i);
    cfg_plot.ax = this_ax;
    cfg_plot.insert_zero = 0; % plot zero xtick
    cfg_plot.fit = 'vline'; % 'gauss', 'kernel', 'vline' or 'none (no fit)
    cfg_plot.plot_vert_zero = 0; % plot vertical dashed line at 0

    plot_hist2(cfg_plot, matrix_obj); % ht, then pca
end

set(gcf, 'Position', [316 253 1160 653]);

%% Cell-by-cell correlation across subjects
for d_i = 1:length(datas)
    cell_coefs{d_i} = cell2mat(calculate_cell_coefs(datas{d_i}));
end

cfg_cell_plot = [];
cfg_cell_plot.ax = subplot(2, 3, 3);
cfg_cell_plot.num_subjs = [length(sub_ids.start.carey), length(sub_ids.start.adr)];
cfg_cell_plot.ylim = [-0.2, 0.6];

[mean_coefs, sem_coefs_types] = plot_cell_by_cell(cfg_cell_plot, cell_coefs, themes);

% Wilcoxon rank sum test for Carey and ADR
ranksum(cell_coefs{1}, cell_coefs{2})

% Wilcoxon signed rank test for Carey vs 0
signrank(cell_coefs{1})
%% Population Vector analysis
for d_i = 1:length(datas)
    data = datas{d_i};
    PV_coefs{d_i} = calculate_PV_coefs(data);
end

%% Plot Population Vector correlation coefficents matrix
cfg_pv_plot = [];
cfg_pv_plot.clim = [-0.2 1];
for d_i = 1:length(datas)
    cfg_pv_plot.ax = subplot(2, 3, 3 + d_i);
    plot_PV(cfg_pv_plot, PV_coefs{d_i});
end

%% Plot off-diagonal of Population Vector correlation
cfg_off_pv_plot = [];
cfg_off_pv_plot.ax = subplot(2, 3, 6);
cfg_off_pv_plot.num_subjs = [length(sub_ids.start.carey), length(sub_ids.start.adr)];
cfg_off_pv_plot.ylim = [0, 1];

for d_i = 1:length(datas)
    off_diag_PV_coefs{d_i} = get_off_dig_PV(PV_coefs{d_i});
end
[mean_coefs, sem_coefs_types] = plot_off_diag_PV(cfg_off_pv_plot, off_diag_PV_coefs, themes);

% Wilcoxon signed rank test for Carey and ADR off-diagonal
ranksum(off_diag_coefs{1}(:), off_diag_coefs{2}(:))
