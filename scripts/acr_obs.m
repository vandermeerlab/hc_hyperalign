% Get Q inputs
cfg_data = [];
mean_Q = prepare_all_Q(cfg_data);

cfg_pre = [];
cfg_pre.hyperalign_all = false;
cfg_pre.predict_Q = true;
[actual_dists_mat, id_dists_mat] = predict_with_L_R(cfg_pre, mean_Q);

n_shuffles = 1000;
sf_dists_mat  = zeros(length(Q), length(Q), n_shuffles);

for i = 1:n_shuffles
    cfg_pre.shuffled = 1;
    [s_actual_dists_mat] = predict_with_L_R(cfg_pre, mean_Q);
    sf_dists_mat(:, :, i) = s_actual_dists_mat;
end
