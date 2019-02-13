% Get Q inputs
cfg_data = [];
cfg_data.use_adr_data = 0;
cfg_data.normalization = 'concat';
Q_norm = prepare_all_Q(cfg_data);

max_coefs = zeros(length(Q_norm), 2);
max_indices = zeros(length(Q_norm), 2);
mean_fr_coefs = zeros(length(Q_norm), 2);

for i = 1:length(Q_norm)
    % Add some small noise so it won't always find 0 for max location.
    L_noise = 0.001 * rand(size(Q_norm{i}.left));
    R_noise = 0.001 * rand(size(Q_norm{i}.right));
    [max_L, ind_L] = max(Q_norm{i}.left + L_noise, [], 2);
    [max_R, ind_R] = max(Q_norm{i}.right + R_noise, [], 2);

    [coef_max, p_max] = corrcoef(max_L, max_R);
    max_coefs(i, 1) = coef_max(1, 2);
    max_coefs(i, 2) = p_max(1, 2);

    [coef_ind, p_ind] = corrcoef(ind_L, ind_R);
    max_indices(i, 1) = coef_ind(1, 2);
    max_indices(i, 2) = p_ind(1, 2);

    L_fr = mean(Q_norm{i}.left, 2);
    R_fr = mean(Q_norm{i}.right, 2);
    [coef_fr, p_fr] = corrcoef(L_fr, R_fr);
    mean_fr_coefs(i, 1) = coef_fr(1, 2);
    mean_fr_coefs(i, 2) = p_fr(1, 2);

end