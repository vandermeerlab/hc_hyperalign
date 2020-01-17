%%
rng(mean('hyperalignment'));
colors = get_hyper_colors();
sub_ids = get_sub_ids_start_end();
n_subjs = length(sub_ids.start.carey);

%% Get simulated inputs.
cfg_sim = [];
cfg_sim.n_units = cellfun(@(x) size(x.left, 1), Q);

Q_xor = L_xor_R(cfg_sim);
Q_ind = L_R_ind(cfg_sim);
Q_sim_HT = sim_HT(cfg_sim);

cfg_sim.same_params = [1, 1, 1];
Q_same_ps = L_R_ind(cfg_sim);

datas = {Q_ind, Q_xor, Q_same_ps, Q_sim_HT};
themes = {'ind-ind', 'x-or', 'ind-same-all', 'sim. HT'};
%% Example inputs
cfg_ex = [];
cfg_ex.n_units = 30;
cfg_ex.n_iters = 1;
ex_xor = L_xor_R(cfg_ex);
ex_ind = L_R_ind(cfg_ex);
ex_same_ps = L_R_ind(struct('same_params', [1, 1, 1], 'n_units', 30, 'n_iters', 1));
ex_sim_HT = sim_HT(cfg_ex);

ex_datas = {ex_ind, ex_xor, ex_same_ps, ex_sim_HT};
for d_i = 1:length(ex_datas)
    subplot(4, 3, (3*(d_i-1) + 1))
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
binsizes = 0.5;

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist};
cfg_plot.fit_colors = {colors.HT.fit};


for d_i = 1:length(datas)
    iter_len = length(actual_dists_mat{d_i});
    sess_len = length(actual_dists_mat{d_i}{1});
    z = zeros(sess_len, sess_len, iter_len);
    for z_i = 1:iter_len
        [z_score] = calculate_common_metrics([], actual_dists_mat{d_i}{z_i}, ...
            id_dists_mat{d_i}{z_i}, sf_dists_mat{d_i}{z_i});
        z(:, :, z_i) = z_score.out_zscore_mat;
    end
    mean_z = nanmean(z, 3);
    z_scores_sim{d_i}.out_zscore_mat = mean_z(:);
    z_scores_sim{d_i}.out_zscore_prop = sum(sum((mean_z < 0))) / sum(sum(~isnan(mean_z)));
    z_scores_sim{d_i}.sr_p = signrank(mean_z(:));
    z_scores_sim{d_i}.out_mean = nanmean(mean_z(:));
    z_scores_sim{d_i}.out_sem = nanstd(mean_z(:)) / sqrt(n_subjs * (n_subjs - 1));
    
    matrix_objs = {{z_scores_sim{d_i}.out_zscore_mat}};
    for m_i = 1:length(matrix_objs)
        this_ax = subplot(4, 3, (3*(d_i-1) + 2));
        p_i = (m_i - 1) * 4 + d_i; % % plot index to access x_limits etc defined above
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

%% Population Vector correlation and Cell-by-cell correlation analysis
for d_i = 1:length(datas)
    data = datas{d_i};
    iter_len = length(data);
    sess_len = length(data{1});
    % Average PV matrices and cell coefficients across all iterations for each session.
    for sess_i = 1:sess_len
        for iter_i = 1:iter_len
            data_acr_iters{sess_i}{iter_i} = data{iter_i}{sess_i};
        end
        PV_coefs_acr_iters = calculate_PV_coefs(data_acr_iters{sess_i});
        mean_PV_coefs_acr_iters{sess_i} = mean(cat(3, PV_coefs_acr_iters{:}), 3);

        cell_coefs_acr_iters = calculate_cell_coefs(data_acr_iters{sess_i});
        mean_cell_coefs_acr_iters{sess_i} = mean(cat(3, cell_coefs_acr_iters{:}), 3);
    end
    PV_coefs{d_i} = mean_PV_coefs_acr_iters;
    cell_coefs{d_i} = cell2mat(mean_cell_coefs_acr_iters);
end

%% Plot Population Vector correlation coefficents matrix
cfg_pv_plot = [];
cfg_pv_plot.clim = [-0.2 1];
for d_i = 1:length(datas)
    cfg_pv_plot.ax = subplot(4, 3, (3*(d_i-1) + 3));
    plot_PV(cfg_pv_plot, PV_coefs{d_i});
end

%% Plot off-diagonal of Population Vector correlation across subjects
PV_coefs{5} = calculate_PV_coefs(Q);
themes = {'ind-ind', 'x-or', 'ind-same-all', 'sim. HT', 'Carey'};

figure;
cfg_off_pv_plot = [];
cfg_off_pv_plot.ax = subplot(2, 1, 1);
cfg_off_pv_plot.num_subjs = repmat(n_subjs, 1, 5);
cfg_off_pv_plot.ylim = [-0.3, 0.5];

for d_i = 1:length(PV_coefs)
    off_diag_PV_coefs{d_i} = get_off_dig_PV(PV_coefs{d_i});
end
[mean_PV_coefs_types, sem_PV_coefs_types] = plot_off_diag_PV(cfg_off_pv_plot, off_diag_PV_coefs, themes);

set(gcf, 'Position', [680 301 559 677]);

%% Plot Cell-by-cell correlation across subjects
cell_coefs{5} = cell2mat(calculate_cell_coefs(Q));
themes = {'ind-ind', 'x-or', 'ind-same-all', 'sim. HT', 'Carey'};

cfg_cell_plot = [];
cfg_cell_plot.ax = subplot(2, 1, 2);
cfg_cell_plot.num_subjs = repmat(n_subjs, 1, 5);

cfg_cell_plot.ylim = [-0.2, 0.5];

[mean_coefs, sem_coefs_types] = plot_cell_by_cell(cfg_cell_plot, cell_coefs, themes);

set(gcf, 'Position', [680 301 559 677]);