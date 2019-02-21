% Last 2.4 second, dt = 50ms for Q
% w_len = 48;
% Or last 41 bins (after all choice points) for TC
w_len = 41;
rng(mean('hyperalignment'));
sim_data = cell(1, 2);
n_units{1} = 50;
n_units{2} = 65;
% Make two Qs - first: source, second: target
for s_i = 1:length(sim_data)
    % Number of neurons
    sim_data{s_i}.left = zeros(n_units{s_i}, w_len);
    p_has_field = 0.25;
    for n_i = 1:n_units{s_i}
        if rand() < p_has_field
            left_mu = rand() * w_len;
            sim_data{s_i}.left(n_i, :) = gaussian_1d(w_len, 5, left_mu, 5);
        end
    end
    sim_data{s_i}.left = zscore(sim_data{s_i}.left, 0, 2);
end

NumComponents = 10;
% Project [L, R] to PCA space.
for p_i = 1:length(sim_data)
    pca_input = [sim_data{p_i}.left];
    sim_pca_mean{p_i} = mean(pca_input, 2);
    pca_input = pca_input - sim_pca_mean{p_i};
    [sim_eigvecs{p_i}] = pca_egvecs(pca_input, NumComponents);
    %  project all other trials (both left and right trials) to the same dimension
    sim_proj_Q{p_i} = pca_project(pca_input, sim_eigvecs{p_i});
end

% Perform hyperalignment on concatenated [L, R] in PCA.
hyper_input = {sim_proj_Q{1}, sim_proj_Q{2}};
[sim_aligned_left, sim_transforms] = hyperalign(hyper_input{:});

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
for rd_i = 1:length(data)
    proj_data{rd_i} = perform_pca(data{rd_i}, NumComponents);
end

% Hyperalignment
[aligned_left, aligned_right] = get_aligned_left_right({proj_data{10}, proj_data{19}});
[~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}');
% Disable scaling
M.b = 1;

for r_i = 1:length(sim_data)
    predicted{r_i} = p_transform(M, sim_aligned_left{r_i});
    project_back_pca{r_i} = inv_p_transform(sim_transforms{r_i}, predicted{r_i});
    sim_data{r_i}.right = sim_eigvecs{r_i} * project_back_pca{r_i} + sim_pca_mean{r_i};
end

%% Set the same color scale for hyper pair and create a polished figure
sim_data_concat{1} = [sim_data{1}.left, sim_data{1}.right];
sim_data_concat{2} = [sim_data{2}.left, sim_data{2}.right];
min_val = min(min(min(sim_data_concat{1})), min(min(sim_data_concat{2})));
max_val = max(max(max(sim_data_concat{1})), max(max(sim_data_concat{2})));

subplot(1, 2, 1)
imagesc(sim_data_concat{1});
caxis([min_val, max_val]);
ylabel('Neurons');
xlabel('Locations');
set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 60);

subplot(1, 2, 2)
imagesc(sim_data_concat{2});
caxis([min_val, max_val]);
ylabel('Neurons');
xlabel('Locations');
set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 60);
