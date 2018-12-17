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

actual_dists_mat  = zeros(length(Q));
sf_dists_mat  = cell(length(Q));
actual_sf_mat = zeros(length(Q));

% Project [L, R] to PCA space.
NumComponents = 10;
for p_i = 1:length(Q)
    [mean_proj_Q{p_i}, eigvecs{p_i}] = perform_pca(mean_Q{p_i}, NumComponents);
end

for sr_i = 1:length(Q)
    for tar_i = 1:length(Q)
        if sr_i ~= tar_i
            % Perform hyperalignment on concatenated [L, R] in PCA.
            hyper_input = {mean_proj_Q{sr_i}, mean_proj_Q{tar_i}};
            [aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);
            % Estimate M from L to R using source session.
            [~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}');
            % Apply M to L of target session to predict.
            predicted = p_transform(M, aligned_left{2});
            % Project back to PCA space
            padding = zeros(size(aligned_left{1}));
            project_back_pca = inv_p_transform(transforms{2}, [padding, predicted]);
            % Project back to Q space.
            w_len = size(mean_proj_Q{1}.left, 2);
            project_back_Q_right = eigvecs{tar_i} * project_back_pca(:, w_len+1:end);
            % Compare prediction using M with ground truth
            ground_truth_Q = mean_Q{tar_i}.right;
            actual_dist = calculate_dist(project_back_Q_right, ground_truth_Q);
            actual_dists_mat(sr_i, tar_i) = actual_dist;
            for rand_i = 1:1000
                % sf_M.c = repmat(rand(1, size(M.c, 2)), size(M.c, 1), 1);
                sf_M.c = zeros(size(M.c));
                sf_M.b = rand();
                sf_M.T = randn(size(M.T));
                s_predicted = p_transform(sf_M, aligned_left{2});
                s_project_back_pca = inv_p_transform(transforms{2}, [padding, s_predicted]);
                s_project_back_Q_right = eigvecs{tar_i} * s_project_back_pca(:, w_len+1:end);

                sf_dist = calculate_dist(s_project_back_Q_right, ground_truth_Q);
                sf_dists_mat{sr_i, tar_i}  = [sf_dists_mat{sr_i, tar_i}, sf_dist];
                if actual_dist < sf_dist
                    actual_sf_mat(sr_i, tar_i) = actual_sf_mat(sr_i, tar_i) + 1;
                end
            end
        end
    end
end
