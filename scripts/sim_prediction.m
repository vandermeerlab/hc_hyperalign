rng(mean('hyperalignment'));

%%
data = Q;

% PCA
NumComponents = 10;
for rd_i = 1:length(data)
    proj_data{rd_i} = perform_pca(data{rd_i}, NumComponents);
end

n_targets = 1;
n_sources = 1000;

sim_data = cell(n_sources, n_targets);

for tar_i = 1:n_targets
%     n_units = size(data{tar_i}.left, 1);
    n_units = 96;
    w_len = size(data{1}.left, 2);
    sim_data{1, tar_i}.left = zeros(n_units, w_len);
    sim_data{1, tar_i}.right = zeros(n_units, w_len);
    p_has_field = 0.5;
    for n_i = 1:n_units
        if rand() < p_has_field
            mu = rand() * w_len;
            peak = rand() * 10 + 10;
            sig = rand() * 5 + 2;
            sim_data{1, tar_i}.left(n_i, :) = gaussian_1d(w_len, peak, mu, sig);
        end
    end
end

for i = 2:n_sources
    sim_data(i, :) = sim_data(1, :);
end

%% Hyperalign real data and simulated data pair version
for sr_i = 1:n_sources
%     real_idx = sr_i;
    real_idx = datasample(1:length(data), 1);
    for tar_i = 1:n_targets
        NumComponents = 10;
        [sim_proj_data{tar_i}, sim_eigvecs{tar_i}, sim_pca_mean{tar_i}] = perform_pca(sim_data{sr_i, tar_i}, NumComponents);
        
        hyper_input = {proj_data{real_idx}, sim_proj_data{tar_i}};
        [aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);
        
        [~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}', 'scaling', false);
        predicted_aligned = p_transform(M, aligned_left{2});
        project_back_pca = inv_p_transform(transforms{2}, [aligned_left{2}, predicted_aligned]);
        project_back_data = sim_eigvecs{tar_i} * project_back_pca + sim_pca_mean{tar_i};
        
        sim_data{sr_i, tar_i}.right = project_back_data(:, w_len+1:end);
    end
end

Q_sim_HT = sim_data;

%% Plot some example data L and R with predicitons (ordered by L of source).
sim_data = Q_sim_HT;
% out_predicted_Q_mat = set_withsubj_nan([], Q_sim_HT);

figure;
set(gcf, 'Position', [540 71 1139 884]);

ex_sess_idx = [2, 6, 9, 15];
for s_i = 1:length(ex_sess_idx)
    sess_idx = ex_sess_idx(s_i);
    example_data = sim_data{1, sess_idx};
    sim_pre_R = [];
    for j = 1:length(Q)
        sim_pre = sim_data{j, sess_idx};
        if isstruct(sim_pre)
            if isempty(sim_pre_R)
                sim_pre_R = sim_pre.right;
            else
                sim_pre_R(:, :, end+1) = sim_pre.right;
            end
        end
    end
    example_data.predict = nanmean(sim_pre_R, 3);
    
    [~, max_idx] = max(example_data.left, [], 2);
    [~, sorted_idx] = sort(max_idx);
    
    subplot(2, 2, s_i)
    imagesc([example_data.left(sorted_idx, :), example_data.predict(sorted_idx, :)]);
    colorbar;
%     caxis([-20, 20]);
    set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 20);
    ylabel('neuron');
end

%% Average across all sessions
sim_pre_R_acr = zeros(n_units, w_len, n_targets);
for i = 1:n_targets
    sim_pre_R = [];
    for j = 1:n_sources
        sim_pre = sim_data{j, i};
        if isstruct(sim_pre)
            if isempty(sim_pre_R)
                sim_pre_R = sim_pre.right;
            else
                sim_pre_R(:, :, end+1) = sim_pre.right;
            end
        end
    end
    avg_sim_pre_R = nanmean(sim_pre_R, 3);
    sim_pre_R_acr(:, :, i) = avg_sim_pre_R;
end

avg_sim_pre_R_acr = nanmean(sim_pre_R_acr, 3);

[~, max_idx] = max(sim_data{1, 1}.left, [], 2);
[~, sorted_idx] = sort(max_idx);
imagesc([sim_data{1, 1}.left(sorted_idx, :), avg_sim_pre_R_acr(sorted_idx, :)]);