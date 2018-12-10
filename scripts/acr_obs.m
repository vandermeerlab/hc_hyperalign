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

% PCA
NumComponents = 10;
for i = 1:length(Q)
    [mean_proj_Q{i}, eigvecs{i}] = perform_pca(mean_Q{i}, NumComponents);
end

% Hyperalignment
[aligned_left, aligned_right, transforms] = get_aligned_left_right(mean_proj_Q);

dist_mat = zeros(length(Q));
dist_LR_mat = zeros(length(Q));

aligned_source = aligned_left;
aligned_target = aligned_right;
for sr_i = 1:length(Q)
    % Find the transform for source subject from left to right in the common space.
    [~, ~, M{sr_i}] = procrustes(aligned_target{sr_i}', aligned_source{sr_i}');
    predicted = cellfun(@(x) p_transform(M{sr_i}, x), aligned_source, 'UniformOutput', false);
    for tar_i = 1:length(Q)
        % Apply inverse procustes to project back to PCA space.
        project_back_pca = inv_p_transform(transforms{tar_i}, [aligned_source{tar_i}, predicted{tar_i}]);
        project_back_pca_id = inv_p_transform(transforms{tar_i}, [aligned_source{tar_i}, aligned_source{tar_i}]);

        % project_back_pca_right = project_back_pca(:, 49:end);
        % project_back_pca_id_right = project_back_pca_id(:, 49:end);
        % Project prediction back to Q space.
        project_back_Q = eigvecs{tar_i} * project_back_pca;
        project_back_Q_right = project_back_Q(:, 49:end);
        % Project identity mapping back to Q space.
        project_back_Q_id = eigvecs{tar_i} * project_back_pca_id;
        project_back_Q_id_right = project_back_Q_id(:, 49:end);

        % Compare with its original right Q
        ground_truth_Q = mean_Q{tar_i}.right;
        dist_mat(sr_i, tar_i) = calculate_dist(project_back_Q_right, ground_truth_Q);
        dist_LR_mat(sr_i, tar_i) = calculate_dist(project_back_Q_id_right, ground_truth_Q);
    end
end

% Shuffle aligned Q matrix
rand_dists_mat  = cell(length(Q), length(Q));
rand_dists_LR_mat  = cell(length(Q), length(Q));
predicted_id_mat = zeros(length(Q));
for i = 1:1000
% %     Shuffling the mean projected matrix (right)
%     for j = 1:length(aligned_right)
%         shuffle_indices{j} = randperm(NumComponents);
%         shuffled_right{j} = mean_proj_Q.right{j}(shuffle_indices{j}, :);
%         s_aligned{j} = p_transform(transforms{j}, [mean_proj_Q.left{j}, shuffled_right{j}]);
%         rand_dists{j} = [rand_dists{j}, calculate_dist(predicted_R{j}, s_aligned{j}(:, t_len+1:end))];
%     end

    mean_s_Q = mean_Q;
    for j = 1:length(Q)
        shuffle_indices{j} = randperm(size(Q{j}.right{1}.data, 1));
        mean_s_Q{j}.right = mean_Q{j}.right(shuffle_indices{j}, :);
    end

     % PCA
    for p_i = 1:length(Q)
        [mean_s_proj_Q{p_i}, s_eigvecs{p_i}] = perform_pca(mean_s_Q{p_i}, NumComponents);
    end

    % Perform hyperalignment on independently shuffled right Q matrix
    [s_aligned_left, s_aligned_right, s_transforms] = get_aligned_left_right(mean_s_proj_Q);

    s_aligned_source = s_aligned_left;
    s_aligned_target = s_aligned_right;
    for s_sr_i = 1:length(Q)
        [~, ~, shuffle_M{s_sr_i}] = procrustes(s_aligned_target{s_sr_i}', s_aligned_source{s_sr_i}');
        s_predicted = cellfun(@(x) p_transform(shuffle_M{s_sr_i}, x), s_aligned_source, 'UniformOutput', false);
        for s_tar_i = 1:length(Q)
            % Apply inverse procustes to project back to PCA space.
            s_project_back_pca = inv_p_transform(s_transforms{s_tar_i}, [s_aligned_source{s_tar_i}, s_predicted{s_tar_i}]);
            s_project_back_pca_id = inv_p_transform(s_transforms{s_tar_i}, [s_aligned_source{s_tar_i}, s_aligned_source{s_tar_i}]);

            % s_project_back_pca_right = s_project_back_pca(:, 49:end);
            % s_project_back_pca_id_right = s_project_back_pca_id(:, 49:end);
            % Project prediction back to Q space.
            s_project_back_Q = s_eigvecs{s_tar_i} * s_project_back_pca;
            s_project_back_Q_right = s_project_back_Q(:, 49:end);
            % Project identity mapping back to Q space.
            s_project_back_Q_id = s_eigvecs{s_tar_i} * s_project_back_pca_id;
            s_project_back_Q_id_right = s_project_back_Q_id(:, 49:end);

            % Compare with its shuffled right Q
            s_ground_truth_Q = mean_s_Q{s_tar_i}.right;
            s_predicted_dist = calculate_dist(s_project_back_Q_right, s_ground_truth_Q);
            s_id_dist = calculate_dist(s_project_back_Q_id_right, s_ground_truth_Q);
            rand_dists_mat{s_sr_i, s_tar_i} = [rand_dists_mat{s_sr_i, s_tar_i}, s_predicted_dist];
            rand_dists_LR_mat{s_sr_i, s_tar_i} = [rand_dists_LR_mat{s_sr_i, s_tar_i}, s_id_dist];
            if s_predicted_dist < s_id_dist
                predicted_id_mat(s_sr_i, s_tar_i) = predicted_id_mat(s_sr_i, s_tar_i) + 1;
            end
        end
    end
end
