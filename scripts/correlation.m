% Get Q inputs
cfg_data = [];
mean_Q = prepare_all_Q(cfg_data);

max_coefs = zeros(length(mean_Q), 2);
max_indices = zeros(length(mean_Q), 2);

for i = 1:length(mean_Q)
    % Add some small noise so it won't always find 0 for max location.
    L_noise = 0.001 * rand(size(mean_Q{i}.left));
    R_noise = 0.001 * rand(size(mean_Q{i}.right));
    [max_L, ind_L] = max(mean_Q{i}.left + L_noise, [], 2);
    [max_R, ind_R] = max(mean_Q{i}.right + R_noise, [], 2);
    
    [coef_max, p_max] = corrcoef(max_L, max_R);
    max_coefs(i, 1) = coef_max(1, 2);
    max_coefs(i, 2) = p_max(1, 2);
    
    [coef_ind, p_ind] = corrcoef(ind_L, ind_R);
    max_indices(i, 1) = coef_ind(1, 2);
    max_indices(i, 2) = p_ind(1, 2);
end