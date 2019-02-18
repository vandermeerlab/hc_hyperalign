% % Get Q inputs
% cfg_data = [];
% cfg_data.use_adr_data = 0;
% cfg_data.normalization = 'concat';
% [Q_norm, Q] = prepare_all_Q(cfg_data);

% Get TC inputs.
cfg_data = [];
cfg_data.only_use_cp = 1;
[TC_norm, TC] = prepare_all_TC(cfg_data);

data = TC_norm;

max_coefs = zeros(length(data), 2);
max_indices = zeros(length(data), 2);

for i = 1:length(data)
    % Add some small noise so it won't always find 0 for max location.
    L_noise = 0.001 * rand(size(data{i}.left));
    R_noise = 0.001 * rand(size(data{i}.right));
    [max_L, ind_L] = max(data{i}.left + L_noise, [], 2);
    [max_R, ind_R] = max(data{i}.right + R_noise, [], 2);

    [coef_max, p_max] = corrcoef(max_L, max_R);
    max_coefs(i, 1) = coef_max(1, 2);
    max_coefs(i, 2) = p_max(1, 2);

    [coef_ind, p_ind] = corrcoef(ind_L, ind_R);
    max_indices(i, 1) = coef_ind(1, 2);
    max_indices(i, 2) = p_ind(1, 2);
end
