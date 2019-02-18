% Last 2.4 second, dt = 50ms
% w_len = 48;
% Or last 41 bins (after all choice points) for TC
w_len = 41;
rng(mean('mvdmlab'));
% Make two Qs - first: source, second: target
for q_i = 1:19
    % Number of neurons
    n_units = randi([30, 120]);
    Q{q_i}.left = zeros(n_units, w_len);
    Q{q_i}.right = zeros(n_units, w_len);
    for n_i = 1:n_units
        mu = rand() * w_len;
        left_has_field = rand() < 0.5;
        if left_has_field
            Q{q_i}.left(n_i, :) = gaussian_1d(w_len, 5, mu, 5);
        else
            Q{q_i}.right(n_i, :) = gaussian_1d(w_len, 5, mu, 5);
        end
    end
    Q_norm_concat = zscore([Q{q_i}.left, Q{q_i}.right], 0, 2);
    Q{q_i}.left = Q_norm_concat(:, 1:w_len);
    Q{q_i}.right = Q_norm_concat(:, w_len+1:end);
end

cfg_pre = [];
[actual_dists_mat, id_dists_mat] = predict_with_L_R(cfg_pre, Q);

n_shuffles = 1000;
sf_dists_mat  = zeros(length(Q), length(Q), n_shuffles);

for i = 1:n_shuffles
    cfg_pre.shuffled = 1;
    [s_actual_dists_mat] = predict_with_L_R(cfg_pre, Q);
    sf_dists_mat(:, :, i) = s_actual_dists_mat;
end
