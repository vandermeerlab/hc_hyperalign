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

actual_dists_mat  = cell(length(Q), length(Q));
sf_dists_mat  = cell(length(Q), length(Q));
id_dists_mat  = cell(length(Q), length(Q));
actual_sf_mat = zeros(length(Q));
actual_id_mat = zeros(length(Q));

for i = 1:1000
    % Shuffle right Q matrices
    mean_s_Q = mean_Q;
    for s_i = 1:length(Q)
        shuffle_indices{s_i} = randperm(size(Q{s_i}.right{1}.data, 1));
        mean_s_Q{s_i}.right = mean_Q{s_i}.right(shuffle_indices{s_i}, :);
    end

     % PCA
     NumComponents = 10;
    for p_i = 1:length(Q)
        % Concatenate Q matrix across left and right trials and perform PCA on it.
        pca_input = [mean_Q{p_i}.left, mean_Q{p_i}.right, mean_s_Q{p_i}.right];
        [eigvecs{p_i}] = pca_egvecs(pca_input, NumComponents);
        %  project all other trials (both left and right trials) to the same dimension
        mean_proj_Q{p_i}.left = pca_project(mean_Q{p_i}.left, eigvecs{p_i});
        mean_proj_Q{p_i}.right = pca_project(mean_Q{p_i}.right, eigvecs{p_i});
        mean_proj_Q{p_i}.s_right = pca_project(mean_s_Q{p_i}.right, eigvecs{p_i});
    end

    % Perform hyperalignment on concatenated [L, R, shuffled_R]
    for h_i = 1:length(Q)
        hyper_input{h_i} = [mean_proj_Q{h_i}.left, mean_proj_Q{h_i}.right, mean_proj_Q{h_i}.s_right];
    end
    [aligned, transforms] = hyperalign(hyper_input{:});
    w_len = size(mean_proj_Q{1}.left, 2);
    aligned_left = cellfun(@(x) x(:, 1:w_len), aligned, 'UniformOutput', false);
    aligned_right = cellfun(@(x) x(:, w_len+1:2*w_len), aligned, 'UniformOutput', false);
    s_aligned_right = cellfun(@(x) x(:, 2*w_len+1:end), aligned, 'UniformOutput', false);

    aligned_source = aligned_left;
    aligned_target = aligned_right;
    s_aligned_target = s_aligned_right;
    for sr_i = 1:length(Q)
        [~, ~, M{sr_i}] = procrustes(aligned_target{sr_i}', aligned_source{sr_i}');
        predicted = cellfun(@(x) p_transform(M{sr_i}, x), aligned_source, 'UniformOutput', false);

        [~, ~, sf_M{sr_i}] = procrustes(s_aligned_target{sr_i}', aligned_source{sr_i}');
        s_predicted = cellfun(@(x) p_transform(sf_M{sr_i}, x), aligned_source, 'UniformOutput', false);

        for tar_i = 1:length(Q)
            % Apply inverse procustes to project back to PCA space.
            padding = zeros(size(aligned_source{tar_i}));
            project_back_pca = inv_p_transform(transforms{tar_i}, [padding, predicted{tar_i}, padding]);
            % project_back_pca_right = project_back_pca(:, w_len+1:2*w_len);

            s_project_back_pca = inv_p_transform(transforms{tar_i}, [padding, s_predicted{tar_i}, padding]);
            % s_project_back_pca_right = s_project_back_pca(:, w_len+1:2*w_len);

            % Also projecting back identity mapping to PCA space.
            project_back_pca_id = inv_p_transform(transforms{tar_i}, [padding, aligned_source{tar_i}, padding]);

            % Project prediction back to Q space.
            project_back_Q = eigvecs{tar_i} * project_back_pca;
            project_back_Q_right = project_back_Q(:, w_len+1:2*w_len);

            s_project_back_Q = eigvecs{tar_i} * s_project_back_pca;
            s_project_back_Q_right = s_project_back_Q(:, w_len+1:2*w_len);

            % Project identity mapping to Q space.
            project_back_Q_id = eigvecs{tar_i} * project_back_pca_id;
            project_back_Q_id_right = project_back_Q_id(:, w_len+1:2*w_len);

            ground_truth_Q = mean_Q{tar_i}.right;

            actual_dist = calculate_dist(project_back_Q_right, ground_truth_Q);
            shuffled_dist = calculate_dist(s_project_back_Q_right, ground_truth_Q);
            id_dist = calculate_dist(project_back_Q_id_right, ground_truth_Q);

            actual_dists_mat{sr_i, tar_i} = [actual_dists_mat{sr_i, tar_i}, actual_dist];
            sf_dists_mat{sr_i, tar_i} = [sf_dists_mat{sr_i, tar_i}, shuffled_dist];
            id_dists_mat{sr_i, tar_i} = [id_dists_mat{sr_i, tar_i}, id_dist];

            if actual_dist < shuffled_dist
                actual_sf_mat(sr_i, tar_i) = actual_sf_mat(sr_i, tar_i) + 1;
            end
            if actual_dist < id_dist
                actual_id_mat(sr_i, tar_i) = actual_id_mat(sr_i, tar_i) + 1;
            end
        end
    end
end
