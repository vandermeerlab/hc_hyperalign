rng(mean('hyperalignment'));
win_len = 48;

putative{1}.left = zeros(100, win_len);
putative{1}.right = zeros(100, win_len);
all_neurons = [];
for i = 1:length(Q)
    all_neurons = [all_neurons; Q{i}.left; Q{i}.right];
end

rand_sample_idx = randsample(length(all_neurons), 200);
putative{1}.left = all_neurons(rand_sample_idx(1:100), :);
putative{1}.right = all_neurons(rand_sample_idx(101:end), :);

% for r_i = 1:length(putative{1}.right)
%     [shuffle_indices] = shift_shuffle(win_len);
%     R_row = putative{1}.right(r_i, :);
%     putative{1}.right(r_i, :) = R_row(shuffle_indices);
% end

imagesc([putative{1}.left, putative{1}.right])

cell_coefs{1} = cell2mat(calculate_cell_coefs(putative));
PV_coefs{1} = calculate_PV_coefs(putative);

%% cell-by-cell
themes = {'cell-by-cell'};
cfg_cell_plot = [];
cfg_cell_plot.num_subjs = [1];
cfg_cell_plot.ylim = [-0.2, 0.6];

[mean_coefs, sem_coefs_types] = plot_cell_by_cell(cfg_cell_plot, cell_coefs, themes);

%% PV
cfg_pv_plot = [];
cfg_pv_plot.clim = [-0.2 1];
plot_PV(cfg_pv_plot, PV_coefs{1});

%% off-diagonal PV
themes = {'off-diag PV'};
cfg_off_pv_plot = [];
cfg_off_pv_plot.num_subjs = [1];
cfg_off_pv_plot.ylim = [-0.3, 0.5];

off_diag_PV_coefs{1} = get_off_dig_PV(PV_coefs{1});

[mean_coefs, sem_coefs_types] = plot_off_diag_PV(cfg_off_pv_plot, off_diag_PV_coefs, themes);
