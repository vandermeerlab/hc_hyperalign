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
    p_has_field = 0.5;
    for n_i = 1:n_units
        % mu = rand() * w_len;
        % peak = rand() * 20;
        % sig = rand() * 5 + 2;
        if rand() < p_has_field
            left_mu = rand() * w_len;
            left_peak = rand() * 20;
            left_sig = rand() * 5 + 2;
            Q{q_i}.left(n_i, :) = gaussian_1d(w_len, left_peak, left_mu, left_sig);
        end
        if rand() < p_has_field
            right_mu = rand() * w_len;
            right_peak = rand() * 20;
            right_sig = rand() * 5 + 2;
            Q{q_i}.right(n_i, :) = gaussian_1d(w_len, right_peak, right_mu, right_sig);
        end
    end
end

% Plot example input
hold on;
subplot(4, 1, 1)
imagesc([Q{1}.left, Q{1}.right]);
set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 40);
title('L R ind.')

norm_methods = {'concat'};
for nm_i = 1:length(norm_methods)
    cfg_pre = [];
    cfg_pre.normalization = norm_methods{nm_i};
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
    subplot(4, 1, nm_i + 1)
    histogram(out_actual_sf_mat, 20)
    set(gca, 'yticklabel', [], 'FontSize', 40)

    % Proportion of distance obtained from M smaller than identity mapping
    out_actual_dists = set_withsubj_nan(actual_dists_mat);
    out_id_dists = set_withsubj_nan(id_dists_mat);
    sum(sum(out_actual_dists < out_id_dists)) / sum(sum(~isnan(out_actual_dists)))
end
