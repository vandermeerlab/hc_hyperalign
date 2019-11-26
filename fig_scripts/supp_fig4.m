%%
rng(mean('hyperalignment'));
colors = get_hyper_colors();
sub_ids = get_sub_ids_start_end();

%%
% Correlation analysis in various simulations: L_R_same_mu, L_R_same_peak, L_R_same_sig
Q_same_mu = L_R_ind(struct('same_params', [1, 0, 0]));
Q_same_peak = L_R_ind(struct('same_params', [0, 1, 0]));
Q_same_sig = L_R_ind(struct('same_params', [0, 0, 1]));

datas = {Q_same_mu, Q_same_peak, Q_same_sig};
themes = {'ind.(same mu)', 'ind.(same amp.)', 'ind.(same width)'};

%% Example inputs
n_units = 30;
ex_same_mu = L_R_ind(struct('same_params', [1, 0, 0], 'n_units', n_units));
ex_same_peak = L_R_ind(struct('same_params', [0, 1, 0], 'n_units', n_units));
ex_same_sig = L_R_ind(struct('same_params', [0, 0, 1], 'n_units', n_units));

ex_datas = {ex_same_mu, ex_same_peak, ex_same_sig};
for d_i = 1:length(ex_datas)
    subplot(3, 3, (3*(d_i-1) + 1))
    imagesc([ex_datas{d_i}{1}{1}.left, ex_datas{d_i}{1}{1}.right]);
    colorbar;
    set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 12);
    ylabel('Cells');
    title(themes{d_i});
end

set(gcf, 'Position', [199 42 1257 954]);

%% Hyperalignment procedure
for d_i = 1:length(datas)
    data = datas{d_i};
    for q_i = 1:length(data)
        [actual_dists_mat{d_i}{q_i}, id_dists_mat{d_i}{q_i}, sf_dists_mat{d_i}{q_i}] = predict_with_shuffles([], data{q_i}, @predict_with_L_R);
    end
end

%% HT prediction in various simulations.
x_limits = [-6.5, 6.5];
x_tick = -6:6;
binsizes = 1;

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist};
cfg_plot.fit_colors = {colors.HT.fit};

for d_i = 1:length(datas)
    [z_score] = calculate_common_metrics([], horzcat(actual_dists_mat{d_i}{:}), ...
    horzcat(id_dists_mat{d_i}{:}), horzcat(sf_dists_mat{d_i}{:}));

    matrix_objs = {{z_score.out_zscore_mat}};
    for m_i = 1:length(matrix_objs)
        this_ax = subplot(3, 3, (3*(d_i-1) + 2));
        p_i = (m_i - 1) * 3 + d_i; % % plot index to access x_limits etc defined above
        matrix_obj = matrix_objs{m_i};

        cfg_plot.xlim = x_limits;
        cfg_plot.xtick = x_tick;
        cfg_plot.binsize = binsizes;
        cfg_plot.ax = this_ax;
        cfg_plot.insert_zero = 1; % plot zero xtick
        cfg_plot.fit = 'vline'; % 'gauss', 'kernel', 'vline' or 'none (no fit)

        plot_hist2(cfg_plot, matrix_obj);

    end
end

%% Population Vector analysis
cfg_pv_plot = [];
cfg_pv_plot.clim = [-0.2 1];
for d_i = 1:length(datas)
    data = datas{d_i};
    cfg_pv_plot.ax = subplot(3, 3, (3*(d_i-1) + 3));
    plot_PV(cfg_pv_plot, horzcat(data{:}));
end

%% Cell-by-cell correlation across subjects
datas = {horzcat(Q_same_mu{:}), horzcat(Q_same_peak{:}), horzcat(Q_same_sig{:}), Q};
themes = {'same mu', 'same amp.', 'same width', 'Carey'};

figure;
cfg_cell_plot = [];
cfg_cell_plot.ax = subplot(2, 1, 1);
sub_ids_starts = [sub_ids.start.carey];
sub_ids_ends = [sub_ids.end.carey];
for i = 2:length(Q)
    sub_ids_starts = [sub_ids_starts, sub_ids.start.carey + (19*(i-1))];
    sub_ids_ends = [sub_ids_ends, sub_ids.end.carey + (19*(i-1))];
end
cfg_cell_plot.sub_ids_starts = cell(size(datas));
cfg_cell_plot.sub_ids_ends = cell(size(datas));
for i = 1:length(datas)
    if i ~= length(datas)
        cfg_cell_plot.sub_ids_starts{i} = sub_ids_starts;
        cfg_cell_plot.sub_ids_ends{i} = sub_ids_ends;
    else
        cfg_cell_plot.sub_ids_starts{i} = sub_ids.start.carey;
        cfg_cell_plot.sub_ids_ends{i} = sub_ids.end.carey;
    end
end
cfg_cell_plot.ylim = [-0.1, 0.5];

plot_cell_by_cell(cfg_cell_plot, datas, themes)

set(gcf, 'Position', [680 315 532 663]);

%% Plot off-diagonal of Population Vector correlation
datas = {horzcat(Q_same_mu{:}), horzcat(Q_same_peak{:}), horzcat(Q_same_sig{:}), Q};
themes = {'same mu', 'same amp.', 'same width', 'Carey'};

cfg_off_pv_plot = [];
cfg_off_pv_plot.ax = subplot(2, 1, 2);
cfg_off_pv_plot.ylim = [-0.3, 0.5];
plot_off_diag_PV(cfg_off_pv_plot, datas, themes);