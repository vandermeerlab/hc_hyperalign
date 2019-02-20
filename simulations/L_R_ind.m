% Last 2.4 second, dt = 50ms
% w_len = 48;
% Or last 41 bins (after all choice points) for TC
w_len = 41;
rng(mean('hyperalignment'));
% Make two Qs - first: source, second: target
for q_i = 1:19
    % Number of neurons
    n_units = randi([30, 120]);
    Q{q_i}.left = zeros(n_units, w_len);
    Q{q_i}.right = zeros(n_units, w_len);
    p_has_field = 0.5;
    for n_i = 1:n_units
%         mu = rand() * w_len;
        if rand() < p_has_field
            left_mu = rand() * w_len;
            left_peak = rand() * 20;
            Q{q_i}.left(n_i, :) = gaussian_1d(w_len, left_peak, left_mu, 5);
        end
        if rand() < p_has_field
            right_mu = rand() * w_len;
            right_peak = rand() * 20;
            Q{q_i}.right(n_i, :) = gaussian_1d(w_len, right_peak, right_mu, 5);
        end
    end
    % Different normalization.
    % Ind. normalization
    Q_norm{q_i}.left = zscore(Q{q_i}.left, 0, 2);
    Q_norm{q_i}.right = zscore(Q{q_i}.right, 0, 2);
    
    % Concat. normalization
    Q_norm_concat = zscore([Q{q_i}.left, Q{q_i}.right], 0, 2);
    Q_norm_concat{q_i}.left = Q_norm_concat(:, 1:w_len);
    Q_norm_concat{q_i}.right = Q_norm_concat(:, w_len+1:end);
end

% Plot example input
hold on;
subplot(3, 3, 2)
imagesc([Q{1}.left, Q{1}.right]);
set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 40);
title('L R ind.')

% Hyperalignment for ind. norm
cfg_pre = [];
[actual_dists_mat, id_dists_mat] = predict_with_L_R(cfg_pre, Q_norm);

n_shuffles = 1000;
sf_dists_mat  = zeros(length(Q), length(Q), n_shuffles);

for i = 1:n_shuffles
    cfg_pre.shuffled = 1;
    [s_actual_dists_mat] = predict_with_L_R(cfg_pre, Q_norm);
    sf_dists_mat(:, :, i) = s_actual_dists_mat;
end

% Proportion of actual distance and identity distance smaller than shuffled distances
actual_sf_mat = sum(actual_dists_mat < sf_dists_mat, 3);
out_actual_sf_mat = set_withsubj_nan(actual_sf_mat) / 1000;
subplot(3, 3, 5)
histogram(out_actual_sf_mat, 20)
set(gca, 'yticklabel', [], 'FontSize', 40)

% Hyperalignment for concat. norm
cfg_pre = [];
[actual_dists_mat, id_dists_mat] = predict_with_L_R(cfg_pre, Q_norm_concat);

n_shuffles = 1000;
sf_dists_mat  = zeros(length(Q), length(Q), n_shuffles);

for i = 1:n_shuffles
    cfg_pre.shuffled = 1;
    [s_actual_dists_mat] = predict_with_L_R(cfg_pre, Q_norm_concat);
    sf_dists_mat(:, :, i) = s_actual_dists_mat;
end

% Proportion of actual distance and identity distance smaller than shuffled distances
actual_sf_mat = sum(actual_dists_mat < sf_dists_mat, 3);
out_actual_sf_mat = set_withsubj_nan(actual_sf_mat) / 1000;
subplot(3, 3, 8)
histogram(out_actual_sf_mat, 20)
set(gca, 'yticklabel', [], 'FontSize', 40)
