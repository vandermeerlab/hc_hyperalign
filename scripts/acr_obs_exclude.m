tic;
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
    mean_Q{i}.right = mean(cat(3, Q_right{:}), 3);
end

% PCA
NumComponents = 10;
for i = 1:length(Q)
    [mean_proj_Q{i}, eigvecs{i}] = perform_pca(mean_Q{i}, NumComponents);
end

dist_mat = zeros(length(Q));
dist_LR_mat = zeros(length(Q));

for sr_i = 1:length(Q)
    % Exclude the data from the sessions we try to predict, i.e padding the right trials with zeros for the target subject
    for ex_i = 1:length(Q)
        if sr_i ~= ex_i
            % Average across left (and right) trials
            ex_mean_Q = mean_Q;
            ex_mean_Q{ex_i}.right = zeros(size(mean_Q{ex_i}.right));

            % PCA
            ex_mean_proj_Q = mean_proj_Q;
            ex_eigvecs = eigvecs;
            [ex_mean_proj_Q{ex_i}, ex_eigvecs{ex_i}] = perform_pca(ex_mean_Q{ex_i}, NumComponents);

            % Perform hyperalignment with excluded data
            [ex_aligned_left, ex_aligned_right, ex_transforms] = get_aligned_left_right(ex_mean_proj_Q);
            % Perform hyperalignment with original data (to get ground truth)
            % [aligned_left, aligned_right, transforms] = get_aligned_left_right(mean_proj_Q);
            % putative_traj = p_transform(ex_transforms{ex_i}, [mean_proj_Q.left{ex_i}, mean_proj_Q.right{ex_i}]);

            aligned_source = ex_aligned_left;
            aligned_target = ex_aligned_right;
            % true_aligned_source = aligned_left;
            % true_aligned_target = aligned_right;
            % true_aligned_target = putative_traj(:, 49:end);

            % Find the transform for source subject from left to right in the common space.
            [~, ~, M{sr_i}] = procrustes(aligned_target{sr_i}', aligned_source{sr_i}');
            % Apply the transform obtained above on target.
            predicted = p_transform(M{sr_i}, aligned_source{ex_i});
            % Apply inverse procustes to project back to PCA space.
            project_back_pca = inv_p_transform(ex_transforms{ex_i}, [aligned_source{ex_i}, predicted]);
            project_back_pca_id = inv_p_transform(ex_transforms{ex_i}, [aligned_source{ex_i}, aligned_source{ex_i}]);

            ground_truth_Q = mean_Q{ex_i}.right;
            % Project prediction back to Q space.
            project_back_Q = ex_eigvecs{ex_i} * project_back_pca;
            project_back_Q_right = project_back_Q(:, 49:end);
            % Project identity mapping back to Q space.
            project_back_Q_id = ex_eigvecs{ex_i} * project_back_pca_id;
            project_back_Q_id_right = project_back_Q_id(:, 49:end);

            % Compare with its original right Q
            dist_mat(sr_i, ex_i) = calculate_dist(project_back_Q_right, ground_truth_Q);
            dist_LR_mat(sr_i, ex_i) = calculate_dist(project_back_Q_id_right, ground_truth_Q);
        else
            dist_mat(sr_i, ex_i) = NaN;
            dist_LR_mat(sr_i, ex_i) = NaN;
        end
    end
end

% Shuffle aligned Q matrix
rand_dists_mat  = cell(length(Q), length(Q));
for i = 1:100
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
    for s_sr_i = 1:length(Q)
        % Exclude the data from the sessions we try to predict, i.e padding the right trials with zeros for the target subject
        for s_ex_i = 1:length(Q)
            if s_sr_i ~= s_ex_i
                ex_mean_s_Q = mean_s_Q;
                ex_mean_s_Q{s_ex_i}.right = zeros(size(mean_Q{s_ex_i}.right));

                ex_mean_s_proj_Q = mean_s_proj_Q;
                ex_s_eigvecs = s_eigvecs;
                [ex_mean_s_proj_Q{s_ex_i}, ex_s_eigvecs{s_ex_i}] = perform_pca(ex_mean_s_Q{s_ex_i}, NumComponents);

                % Perform hyperalignment with excluded data
                [ex_s_aligned_left, ex_s_aligned_right, ex_s_transforms] = get_aligned_left_right(ex_mean_s_proj_Q);
                % Perform hyperalignment with original data (to get ground truth)
                % [s_aligned_left, s_aligned_right, s_transforms] = get_aligned_left_right(mean_s_proj_Q);
                % s_putative_traj = p_transform(ex_s_transforms{s_ex_i}, [mean_s_proj_Q.left{s_ex_i}, mean_s_proj_Q.right{s_ex_i}]);

                s_aligned_source = ex_s_aligned_left;
                s_aligned_target = ex_s_aligned_right;
                % s_true_aligned_target = s_aligned_right;
                % s_true_aligned_target = s_putative_traj(:, 49:end);

                % Find the transform for source subject from left to right in the common space.
                [~, ~, shuffle_M{s_sr_i}] = procrustes(s_aligned_target{s_sr_i}', s_aligned_source{s_sr_i}');
                s_predicted = p_transform(shuffle_M{s_sr_i}, s_aligned_source{s_ex_i});

                s_project_back_pca = inv_p_transform(ex_s_transforms{s_ex_i}, [s_aligned_source{s_ex_i}, s_predicted]);
                s_project_back_pca_id = inv_p_transform(ex_s_transforms{s_ex_i}, [s_aligned_source{s_ex_i}, s_aligned_source{s_ex_i}]);
                s_ground_truth_Q = mean_s_Q{s_ex_i}.right;

                s_project_back_Q = ex_s_eigvecs{s_ex_i} * s_project_back_pca;
                s_project_back_Q_right = s_project_back_Q(:, 49:end);

                s_project_back_Q_id = ex_s_eigvecs{s_ex_i} * s_project_back_pca_id;
                s_project_back_Q_id_right = s_project_back_Q_id(:, 49:end);

                % Compare with its shuffled original right Q
                rand_dists_mat{s_sr_i, s_ex_i} = [rand_dists_mat{s_sr_i, s_ex_i}, calculate_dist(s_project_back_Q_right,s_ground_truth_Q)];
            else
                rand_dists_mat{s_sr_i, s_ex_i} = NaN;
            end
        end
    end
end
toc;
