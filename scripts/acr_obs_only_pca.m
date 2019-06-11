%% Get Q inputs.
cfg_data = [];
cfg_data.use_adr_data = 0;
cfg_data.removeInterneurons = 1;
[Q] = prepare_all_Q(cfg_data);

%% Get TC inputs.
cfg_data = [];
cfg_data.only_use_cp = 1;
[TC_norm, TC] = prepare_all_TC(cfg_data);

%% Main Procedure
data = Q;
cfg_pre = [];
cfg_pre.normalization = 'none';
[actual_dists_mat, id_dists_mat] = predict_with_L_R_pca(cfg_pre, data);

%% Shuffling operations
n_shuffles = 1000;
sf_dists_mat  = zeros(length(data), length(data), n_shuffles);

for i = 1:n_shuffles
    cfg_pre.shuffled = 1;
    [s_actual_dists_mat] = predict_with_L_R_pca(cfg_pre, data);
    sf_dists_mat(:, :, i) = s_actual_dists_mat;
end
