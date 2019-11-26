rng(mean('hyperalignment'));
colors = get_hyper_colors();
sub_ids = get_sub_ids_start_end();

% Correlation analysis in Carey and ADR
datas = {Q, adr_Q};
themes = {'Carey', 'ADR'};

%% Hyperalignment procedure
% Carey: 1, ADR: 2;
datas = {Q, adr_Q};
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
    [~, ~, ~, M_ID] = calculate_common_metrics(cfg_metric, actual_dists_mat{d_i}, ...
        id_dists_mat{d_i}, sf_dists_mat{d_i});

    matrix_obj = {M_ID.out_actual_dists, M_ID.out_id_dists};
    bino_ps(d_i) = calculate_bino_p(sum(sum(matrix_obj{1} < matrix_obj{2})), sum(sum(~isnan(matrix_obj{1}))), 0.5);
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
cfg_cell_plot = [];
cfg_cell_plot.ax = subplot(2, 3, 3);
cfg_cell_plot.sub_ids_starts = {sub_ids.start.carey, sub_ids.start.adr};
cfg_cell_plot.sub_ids_ends = {sub_ids.end.carey, sub_ids.end.adr};
cfg_cell_plot.ylim = [-0.1, 0.5];

[mean_coefs, sem_coefs_types, all_coefs_types] = plot_cell_by_cell(cfg_cell_plot, datas, themes);

% Wilcoxon signed rank test for Carey and ADR cell-by-cell
ranksum(all_coefs_types{1}, all_coefs_types{2})
%% Population Vector analysis
cfg_pv_plot = [];
cfg_pv_plot.clim = [-0.2 1];
for d_i = 1:length(datas)
    data = datas{d_i};
    cfg_pv_plot.ax = subplot(2, 3, 3 + d_i);
    plot_PV(cfg_pv_plot, data);
end

%% Plot off-diagonal of Population Vector correlation
cfg_off_pv_plot = [];
cfg_off_pv_plot.ax = subplot(2, 3, 6);
cfg_off_pv_plot.ylim = [0, 1];

[mean_coefs, sd_coefs, all_coefs_types] = plot_off_diag_PV(cfg_off_pv_plot, datas, themes);

% Wilcoxon signed rank test for Carey and ADR off-diagonal
ranksum(all_coefs_types{1}, all_coefs_types{2})