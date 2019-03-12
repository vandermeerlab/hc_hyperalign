% % Get Q inputs.
cfg_data = [];
cfg_data.use_adr_data = 1;
[Q] = prepare_all_Q(cfg_data);

% Get TC inputs.
cfg_data = [];
cfg_data.only_use_cp = 1;
[TC] = prepare_all_TC(cfg_data);

data = TC;
cfg_pre = [];
cfg_pre.hyperalign_all = false;
cfg_pre.predict_Q = true;
cfg_pre.normalization = 'concat';
[actual_dists_mat, id_dists_mat, predicted_Q_mat] = predict_with_L_R(cfg_pre, data);

n_shuffles = 1000;
sf_dists_mat  = zeros(length(data), length(data), n_shuffles);

for i = 1:n_shuffles
    cfg_pre.shuffled = 1;
    [s_actual_dists_mat] = predict_with_L_R(cfg_pre, data);
    sf_dists_mat(:, :, i) = s_actual_dists_mat;
end
