%% Prepare input
% Last 2.4 second, dt = 50ms
% w_len = 48;
% Or last 41 bins (after all choice points) for TC
w_len = 41;
rng(mean('hyperalignment'));
% Make two Qs - first: source, second: target
for q_i = 1:19
    % Number of neurons
    n_units = randi([60, 120]);
    Q{q_i}.left = zeros(n_units, w_len);
    Q{q_i}.right = zeros(n_units, w_len);
    for n_i = 1:n_units
        mu = rand() * w_len;
        peak = rand() * 20;
        sig = rand() * 5 + 2;
        left_has_field = rand() < 0.5;
        if left_has_field
            Q{q_i}.left(n_i, :) = gaussian_1d(w_len, peak, mu, sig);
        else
            Q{q_i}.right(n_i, :) = gaussian_1d(w_len, peak, mu, sig);
        end
    end
    % Different normalization.
    % Ind. normalization
    Q_norm_ind{q_i} = normalize_Q('ind', Q{q_i});
    % Concat. normalization
    Q_norm_concat{q_i} = normalize_Q('concat', Q{q_i});
end

%% Plot example input
hold on;
subplot(4, 1, 1)
imagesc([Q{1}.left, Q{1}.right]);
set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 40);
title('L xor R')

%% Hyperalignment procedure
cfg_pre = [];
[actual_dists_mat, id_dists_mat] = predict_with_L_R(cfg_pre, Q);

n_shuffles = 1000;
sf_dists_mat  = zeros(length(Q), length(Q), n_shuffles);

for i = 1:n_shuffles
    cfg_pre.shuffled = 1;
    [s_actual_dists_mat] = predict_with_L_R(cfg_pre, Q);
    sf_dists_mat(:, :, i) = s_actual_dists_mat;
end

% Proportion of actual distance and identity distance smaller than shuffled distances
actual_sf_mat = sum(actual_dists_mat < sf_dists_mat, 3);
out_actual_sf_mat = set_withsubj_nan(actual_sf_mat) / 1000;
subplot(4, 1, 2)
histogram(out_actual_sf_mat, 20)
set(gca, 'yticklabel', [], 'FontSize', 40)