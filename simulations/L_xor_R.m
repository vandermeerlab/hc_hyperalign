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

hold on;
subplot(2, 3, 1)
imagesc([Q{1}.left, Q{1}.right]);
ylabel('Neurons');
xlabel('Locations');
set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 40);
title('L xor R')

% Proportion of actual distance and identity distance smaller than shuffled distances
actual_sf_mat = sum(actual_dists_mat < sf_dists_mat, 3);
out_actual_sf_mat = set_withsubj_nan(actual_sf_mat) / 1000;
subplot(2, 3, 4)
histogram(out_actual_sf_mat, 20)
ylabel('# of pairs');
xlabel('Proportion > shuffled');
set(gca, 'yticklabel', [], 'FontSize', 40)
