% Last 2.4 second, dt = 50ms
w_len = 48;
% Make two Qs - first: source, second: target
for q_i = 1:19
    % Number of neurons
    n_units = randi([40, 160]);
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