% Last 2.4 second, dt = 50ms
w_len = 48;
% Make two Qs - first: source, second: target
for q_i = 1:2
    % Number of neurons
    n_units = randi([40, 160]);
    Q{q_i}.left = zeros(n_units, w_len);
    Q{q_i}.right = zeros(n_units, w_len);
    p_has_field = 0.5;
    for n_i = 1:n_units
        if rand() < p_has_field
            left_mu = rand() * w_len;
            Q{q_i}.left(n_i, :) = gaussian_1d(w_len, 5, left_mu, 5);
        end
    end
end

NumComponents = 10;
% Project [L, R] to PCA space.
for p_i = 1:length(Q)
    [proj_Q{p_i}, eigvecs{p_i}] = perform_pca(Q{p_i}, NumComponents);
end

% Perform hyperalignment on concatenated [L, R] in PCA.
hyper_input = {proj_Q{1}, proj_Q{2}};
[aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);

% Use M from real data
% Get real Q inputs.
cfg_data = [];
real_Q = prepare_all_Q(cfg_data);
% PCA
NumComponents = 10;
for rq_i = 1:length(real_Q)
    r_proj_Q{rq_i} = perform_pca(real_Q{rq_i}, NumComponents);
end

% Hyperalignment
[r_aligned_left, r_aligned_right] = get_aligned_left_right({r_proj_Q{1}, r_proj_Q{19}});
[~, ~, M] = procrustes(r_aligned_right{1}', r_aligned_left{1}');
% Disable scaling
M.b = 1;

for q_i = 1:length(Q)
    predicted{q_i} = p_transform(M, aligned_left{q_i});
    project_back_pca{q_i} = inv_p_transform(transforms{q_i}, [aligned_left{q_i}, predicted{q_i}]);
    Q{q_i}.right = eigvecs{q_i} * project_back_pca{q_i}(:, w_len+1:end);
end
