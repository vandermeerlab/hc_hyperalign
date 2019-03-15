% Make R be a copy of L plus some noise, identity mapping should be better than random.
% Test the hypothesis in this link: https://mvdmlab.slack.com/archives/C21EB2MUJ/p1549656542130200
% Get Q inputs.
cfg_data = [];
cfg_data.use_adr_data = 0;
[Q_norm, Q] = prepare_all_Q(cfg_data);
for q_i = 1:length(Q)
    Q_norm{q_i}.right = Q_norm{q_i}.left + zscore(rand(size(Q_norm{q_i}.right)), 0, 2);
end

data = Q_norm;
cfg_pre = [];
cfg_pre.hyperalign_all = false;
cfg_pre.predict_target = 'Q';
[actual_dists_mat, id_dists_mat, predicted_mat, pca_mean] = predict_with_L_R(cfg_pre, data);

n_shuffles = 1000;
sf_dists_mat  = zeros(length(data), length(data), n_shuffles);

for i = 1:n_shuffles
    cfg_pre.shuffled = 1;
    [s_actual_dists_mat] = predict_with_L_R(cfg_pre, data);
    sf_dists_mat(:, :, i) = s_actual_dists_mat;
end
