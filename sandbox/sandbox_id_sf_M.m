% Get processed data
cfg_data.paperSessions = 1;
data_paths = getTmazeDataPath(cfg_data);
restrictionLabels = get_restriction_types(data_paths);

cfg.use_matched_trials = 1;
Q = cell(1, length(data_paths));
for p_i = 1:length(data_paths)
    Q{p_i} = get_processed_Q(cfg, data_paths{p_i});
end

% Average across all left (and right) trials
for i = 1:length(Q)
    Q_left = cellfun(@(x) x.data, Q{i}.left, 'UniformOutput', false);
    Q_right = cellfun(@(x) x.data, Q{i}.right, 'UniformOutput', false);
    mean_Q{i}.left = mean(cat(3, Q_left{:}), 3);
    mean_Q{i}.right =  mean(cat(3, Q_right{:}), 3);
end


sf_dists_mat  = cell(length(Q), 1);
id_dists_mat  = cell(length(Q), 1);
sf_id_mat = zeros(length(Q), 1);

for i = 1:1000
    % Shuffle right Q matrix
    mean_s_Q = mean_Q;
    for s_i = 1:length(Q)
        shuffle_indices{s_i} = randperm(size(Q{s_i}.right{1}.data, 1));
        mean_s_Q{s_i}.right = mean_Q{s_i}.right(shuffle_indices{s_i}, :);
    end

    % Project [L, R'] to PCA space.
     NumComponents = 10;
    for p_i = 1:length(Q)
        % Concatenate Q matrix across left and right trials and perform PCA on it.
        pca_input = [mean_Q{p_i}.left, mean_s_Q{p_i}.right];
        [eigvecs{p_i}] = pca_egvecs(pca_input, NumComponents);
        %  project all other trials (both left and right trials) to the same dimension
        mean_proj_Q{p_i}.left = pca_project(mean_Q{p_i}.left, eigvecs{p_i});
        mean_proj_Q{p_i}.s_right = pca_project(mean_s_Q{p_i}.right, eigvecs{p_i});
    end

    % Perform hyperalignment on concatenated [L, shuffled_R] in PCA
    for h_i = 1:length(Q)
        hyper_input{h_i} = [mean_proj_Q{h_i}.left, mean_proj_Q{h_i}.s_right];
    end
    [aligned, transforms] = hyperalign(hyper_input{:});
    w_len = size(mean_proj_Q{1}.left, 2);
    aligned_left = cellfun(@(x) x(:, 1:w_len), aligned, 'UniformOutput', false);
    s_aligned_right = cellfun(@(x) x(:, w_len+1:end), aligned, 'UniformOutput', false);

    aligned_source = aligned_left;
    s_aligned_target = s_aligned_right;
    for sr_i = 1:length(Q)
        % Estimate M' from L to R'.
        [~, ~, sf_M{sr_i}] = procrustes(s_aligned_target{sr_i}', aligned_source{sr_i}');
        % Apply M' to L to predict.
        s_predicted = p_transform(sf_M{sr_i}, aligned_source{sr_i});
        % Project back to PCA space
        padding = zeros(size(aligned_source{sr_i}));
        s_project_back_pca = inv_p_transform(transforms{sr_i}, [padding, s_predicted]);
        % Estimate M only using L (identity mapping).
        project_back_pca_id = inv_p_transform(transforms{sr_i}, [padding, aligned_source{sr_i}]);
        % Project back to Q space.
        s_project_back_Q_right = eigvecs{sr_i} * s_project_back_pca(:, w_len+1:end);
        project_back_Q_id_right = eigvecs{sr_i} * project_back_pca_id(:, w_len+1:end);
        % Compare prediction from M ro M' is better
        ground_truth_Q = mean_Q{sr_i}.right;
        shuffled_dist = calculate_dist(s_project_back_Q_right, ground_truth_Q);
        id_dist = calculate_dist(project_back_Q_id_right, ground_truth_Q);

        sf_dists_mat{sr_i} = [sf_dists_mat{sr_i}, shuffled_dist];
        id_dists_mat{sr_i} = [id_dists_mat{sr_i}, id_dist];
        if id_dist < shuffled_dist
            sf_id_mat(sr_i) = sf_id_mat(sr_i) + 1;
        end
    end
end
