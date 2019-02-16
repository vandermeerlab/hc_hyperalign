% Last 2.4 second, dt = 50ms
% Or last 41 bins (after all choice points) for TC
w_len = 41;
rng(mean('cosyne'));
% Make two Qs - first: source, second: target
for q_i = 1:2
    % Number of neurons
    n_units = randi([30, 120]);
    sim_data{q_i}.left = zeros(n_units, w_len);
    sim_data{q_i}.right = zeros(n_units, w_len);
    p_has_field = 0.25;
    for n_i = 1:n_units
        if rand() < p_has_field
            left_mu = rand() * w_len;
            sim_data{q_i}.left(n_i, :) = gaussian_1d(w_len, 5, left_mu, 5);
        end
    end
    sim_data_concat{q_i} = zscore([sim_data{q_i}.left, sim_data{q_i}.right], 0, 2);
    sim_data{q_i}.left = sim_data_concat{q_i}(:, 1:w_len);
    sim_data{q_i}.right = sim_data_concat{q_i}(:, w_len+1:end);
end

NumComponents = 10;
% Project [L, R] to PCA space.
for p_i = 1:length(sim_data)
    [sim_proj_Q{p_i}, sim_eigvecs{p_i}, sim_pca_mean{p_i}] = perform_pca(sim_data{p_i}, NumComponents);
end

% Perform hyperalignment on concatenated [L, R] in PCA.
hyper_input = {sim_proj_Q{1}, sim_proj_Q{2}};
[sim_aligned_left, sim_aligned_right, sim_transforms] = get_aligned_left_right(hyper_input);

% Use M from real data
% Get real Q inputs.
% cfg_data = [];
% [Q_norm, Q] = prepare_all_Q(cfg_data);

% Get real TC inputs.
cfg_data = [];
[TC_norm, TC] = prepare_all_TC(cfg_data);

data = TC_norm;

% PCA
NumComponents = 10;
for rq_i = 1:length(data)
    proj_data{rq_i} = perform_pca(data{rq_i}, NumComponents);
end

% Hyperalignment
[aligned_left, aligned_right] = get_aligned_left_right({proj_data{10}, proj_data{19}});
[~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}');
% Disable scaling
M.b = 1;

for q_i = 1:length(sim_data)
    predicted{q_i} = p_transform(M, sim_aligned_left{q_i});
    project_back_pca{q_i} = inv_p_transform(sim_transforms{q_i}, [sim_aligned_left{q_i}, predicted{q_i}]);
    sim_data{q_i}.right = sim_eigvecs{q_i} * project_back_pca{q_i}(:, w_len+1:end) + sim_pca_mean{q_i};
end

%% Set the same color scale for hyper pair and create a polished figure
min_val = min(min(min(sim_data_concat{1})), min(min(sim_data_concat{2})));
max_val = max(max(max(sim_data_concat{1})), max(max(sim_data_concat{2})));

subplot(1, 2, 1)
imagesc(sim_data_concat{1});
caxis([min_val, max_val]);

subplot(1, 2, 2)
imagesc(sim_data_concat{2});
caxis([min_val, max_val]);