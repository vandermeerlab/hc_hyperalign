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
% Only for this for dimensions of M.
[~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}');
rand_M.c = zeros(size(M.c));
% 1 if we don't want scaling.
rand_M.b = 1;
rand_M.T = randn(size(M.T));

for q_i = 1:length(Q)
    predicted{q_i} = p_transform(rand_M, aligned_left{q_i});
    project_back_pca{q_i} = inv_p_transform(transforms{q_i}, [aligned_left{q_i}, predicted{q_i}]);
    Q{q_i}.right = eigvecs{q_i} * project_back_pca{q_i}(:, w_len+1:end);
end
