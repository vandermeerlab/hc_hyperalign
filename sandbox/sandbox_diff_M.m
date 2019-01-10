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
        % mean_s_Q{s_i}.right = zscore(randn(size(mean_Q{s_i}.right)), 0, 2);
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

    for sr_i = 1:length(Q)
        for tar_i = 1:length(Q)
            if sr_i ~= tar_i
                % Perform hyperalignment on concatenated [L, R, R']
                hyper_input = {mean_proj_Q{sr_i}, mean_proj_Q{tar_i}};
                [aligned_left, aligned_right, s_aligned_right, transforms] = get_aligned_left_right_s(hyper_input);
                % Estimate M from L to R using source session.
                [~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}');
                % Apply M to L of target session to predict.
                predicted = p_transform(M, aligned_left{2});
                % Estimate M' from L to R' using source session.
                [~, ~, sf_M] = procrustes(s_aligned_right{1}', aligned_left{1}');
                % Apply M' to L of target session to predict.
                s_predicted = p_transform(sf_M, aligned_left{2});
                % Project back to PCA space.
                padding = zeros(size(aligned_left{1}));
                project_back_pca = inv_p_transform(transforms{2}, [padding, predicted, padding]);
                s_project_back_pca = inv_p_transform(transforms{2}, [padding, s_predicted, padding]);
                % Project back to Q space.
                w_len = size(mean_proj_Q{1}.left, 2);
                project_back_Q_right = eigvecs{tar_i} * project_back_pca(:, w_len+1:2*w_len);
                s_project_back_Q_right = eigvecs{tar_i} * s_project_back_pca(:, w_len+1:2*w_len);
                % Compare prediction using M and M' with ground truth respectively.
                ground_truth_Q = mean_Q{tar_i}.right;

                actual_dist = calculate_dist(project_back_Q_right, ground_truth_Q);
                shuffled_dist = calculate_dist(s_project_back_Q_right, ground_truth_Q);

                actual_dists_mat{sr_i, tar_i} = [actual_dists_mat{sr_i, tar_i}, actual_dist];
                sf_dists_mat{sr_i, tar_i} = [sf_dists_mat{sr_i, tar_i}, shuffled_dist];
                if actual_dist < shuffled_dist
                    actual_sf_mat(sr_i, tar_i) = actual_sf_mat(sr_i, tar_i) + 1;
                end
            end
        end
    end
end
