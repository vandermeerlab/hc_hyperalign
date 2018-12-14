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
id_dists_mat  = zeros(length(Q));
sf_dists_mat  = cell(length(Q));
actual_sf_mat = zeros(length(Q));
id_sf_mat = zeros(length(Q));

% Project [L, R] to PCA space.
 NumComponents = 10;
for p_i = 1:length(Q)
    [mean_proj_Q{p_i}, eigvecs{p_i}] = perform_pca(mean_Q{p_i}, NumComponents);
end

% Perform hyperalignment on concatenated [L, R] in PCA.
% hyper_input = mean_proj_Q;
% [aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);

% Exclude right Q from target session that we try to predict.
for ex_i = 1:length(Q)
    ex_mean_Q = mean_Q;
    ex_mean_Q{ex_i}.right = zeros(size(mean_Q{ex_i}.right));
    % PCA
    [ex_mean_proj_Q{ex_i}, ex_eigvecs{ex_i}] = perform_pca(ex_mean_Q{ex_i}, NumComponents);
end

for sr_i = 1:length(Q)
    for tar_i = 1:length(Q)
        if sr_i ~= tar_i
            % Perform hyperalignment on concatenated [L, R] in PCA.
            hyper_input = {mean_proj_Q{sr_i}, ex_mean_proj_Q{tar_i}};
            [aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);
            % Estimate M from L to R using source session.
            [~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}');
            % Apply M to L of target session to predict.
            predicted = p_transform(M, aligned_left{2});
            % Estimate using L (identity mapping).
            id_predicted = aligned_left{2};
            % Project back to PCA space
            padding = zeros(size(aligned_left{1}));
            project_back_pca = inv_p_transform(transforms{2}, [padding, predicted]);
            project_back_pca_id = inv_p_transform(transforms{2}, [padding, id_predicted]);
            % Project back to Q space.
            w_len = size(mean_proj_Q{1}.left, 2);
            project_back_Q_right = ex_eigvecs{tar_i} * project_back_pca(:, w_len+1:end);
            project_back_Q_id_right = ex_eigvecs{tar_i} * project_back_pca_id(:, w_len+1:end);
            % Compare prediction using M with ground truth
            ground_truth_Q = mean_Q{tar_i}.right;
            actual_dists_mat(sr_i, tar_i) = calculate_dist(project_back_Q_right, ground_truth_Q);
            id_dists_mat(sr_i, tar_i) = calculate_dist(project_back_Q_id_right, ground_truth_Q);
        end
    end
end

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
        [mean_s_proj_Q{p_i}, s_eigvecs{p_i}] = perform_pca(mean_s_Q{p_i}, NumComponents);
    end

    for sr_i = 1:length(Q)
        % s_hyper_input = mean_proj_Q;
        % s_hyper_input{sr_i} = mean_s_proj_Q{sr_i};
        % [s_aligned_left, s_aligned_right, s_transforms] = get_aligned_left_right(s_hyper_input);
        % [~, ~, sf_M] = procrustes(s_aligned_right{sr_i}', s_aligned_left{sr_i}');
        for tar_i = 1:length(Q)
            if sr_i ~= tar_i
                % Perform hyperalignment on concatenated [L, R'] in PCA.
                s_hyper_input = {mean_s_proj_Q{sr_i}, ex_mean_proj_Q{tar_i}};
                [s_aligned_left, s_aligned_right, s_transforms] = get_aligned_left_right(s_hyper_input);
                % Estimate M' from L to R' using source session.
                [~, ~, sf_M] = procrustes(s_aligned_right{1}', s_aligned_left{1}');
                % Apply M' to L of target session to predict.
                s_predicted = p_transform(sf_M, s_aligned_left{2});
                % Project back to PCA space
                s_project_back_pca = inv_p_transform(s_transforms{2}, [padding, s_predicted]);
                % Project back to Q space.
                s_project_back_Q_right = ex_eigvecs{tar_i} * s_project_back_pca(:, w_len+1:end);
                % Compare prediction using M' with ground truth
                ground_truth_Q = mean_Q{tar_i}.right;
                sf_dist = calculate_dist(s_project_back_Q_right, ground_truth_Q);
                sf_dists_mat{sr_i, tar_i}  = [sf_dists_mat{sr_i, tar_i}, sf_dist];

                if actual_dists_mat(sr_i, tar_i) < sf_dist
                    actual_sf_mat(sr_i, tar_i) = actual_sf_mat(sr_i, tar_i) + 1;
                end
                if id_dists_mat(sr_i, tar_i) < sf_dist
                    id_sf_mat(sr_i, tar_i) = id_sf_mat(sr_i, tar_i) + 1;
                end
            end
        end
    end
end
