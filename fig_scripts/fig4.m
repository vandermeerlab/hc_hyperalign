rng(mean('hyperalignment'));
colors = get_hyper_colors();
sub_ids = get_sub_ids_start_end();

% Correlation analysis in various simulations: L_R_ind, L_xor_R, L_R_same_μ, sim_HT
datas = {Q_ind, Q_xor, Q_same_mu, Q_sim_HT};
themes = {'ind.', 'x-or', 'ind.(same ?)', 'sim. HT'};
%% Example inputs
cfg_ex = [];
cfg_ex.n_units = 30;
ex_xor = L_xor_R(cfg_ex);
ex_ind = L_R_ind(cfg_ex);
ex_same_mu = L_R_ind(struct('same_mu', 1, 'n_units', 30));
ex_sim_HT = sim_HT(cfg_ex);

ex_datas = {ex_ind, ex_xor, ex_same_mu, ex_sim_HT};
for d_i = 1:length(ex_datas)
    subplot(4, 4, (4*(d_i-1) + 1))
    imagesc([ex_datas{d_i}{1}{1}.left, ex_datas{d_i}{1}{1}.right]);
    colorbar;
    set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 12);
    ylabel('Cells');
    title(themes{d_i});
end

set(gcf, 'Position', [179 7 1299 948]);

%% Hyperalignment procedure
for d_i = 1:length(datas)
    data = datas{d_i};
    for q_i = 1:length(data)
        [actual_dists_mat{d_i}{q_i}, id_dists_mat{d_i}{q_i}, sf_dists_mat{d_i}{q_i}] = predict_with_shuffles([], data{q_i}, @predict_with_L_R);
    end
end

%% HT prediction in various simulations.
x_limits = {[-15, 15], [-15, 15], [-40, 40], [-80, 80]};
x_tick = {-15:2.5:15, -15:2.5:15, -40:20:40, -80:20:80};
binsizes = [1.5, 1.5, 4, 5];

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist};
cfg_plot.fit_colors = {colors.HT.fit};

for d_i = 1:length(datas)
    [~, mean_shuffles, ~, ~] = calculate_common_metrics([], horzcat(actual_dists_mat{d_i}{:}), ...
    horzcat(id_dists_mat{d_i}{:}), horzcat(sf_dists_mat{d_i}{:}));

    matrix_objs = {{mean_shuffles.out_actual_mean_sf}};
    for m_i = 1:length(matrix_objs)
        this_ax = subplot(4, 4, (4*(d_i-1) + 2));
        p_i = (m_i - 1) * 4 + d_i; % % plot index to access x_limits etc defined above
        matrix_obj = matrix_objs{m_i};

        cfg_plot.xlim = x_limits{p_i};
        cfg_plot.xtick = x_tick{p_i};
        cfg_plot.binsize = binsizes(p_i);
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
    cfg_pv_plot.ax = subplot(4, 4, (4*(d_i-1) + 3));
    plot_PV(cfg_pv_plot, horzcat(data{:}));
end

%% Cell-by-cell correlation across subjects
datas = {horzcat(Q_ind{:}), horzcat(Q_xor{:}), horzcat(Q_same_mu{:}), horzcat(Q_sim_HT{:}), Q};
themes = {'ind.', 'x-or', 'same μ', 'sim. HT', 'Carey'};

cfg_cell_plot = [];
cfg_cell_plot.ax = subplot(4, 4, 8);
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
cfg_cell_plot.ylim = [-0.05, 0.45];

plot_cell_by_cell(cfg_cell_plot, datas, themes)

%% Plot off-diagonal of Population Vector correlation
datas = {horzcat(Q_ind{:}), horzcat(Q_xor{:}), horzcat(Q_same_mu{:}), horzcat(Q_sim_HT{:}), Q};
themes = {'ind.', 'x-or', 'same μ', 'sim. HT', 'Carey'};

cfg_off_pv_plot = [];
cfg_off_pv_plot.ax = subplot(4, 4, 12);
cfg_off_pv_plot.ylim = [-0.3, 0.6];
plot_off_diag_PV(cfg_off_pv_plot, datas, themes);
