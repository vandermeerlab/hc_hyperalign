% Get processed data
cfg_data.paperSessions = 1;
data_paths = getTmazeDataPath(cfg_data);
restrictionLabels = get_restriction_types(data_paths);

cfg.use_matched_trials = 1;
Q = cell(1, length(data_paths));
for p_i = 1:length(data_paths)
    Q{p_i} = get_processed_Q(cfg, data_paths{p_i});
end

% PCA
NumComponents = 10;
for i = 1:length(Q)
    proj_Q{i} = perform_pca(Q{i}, NumComponents);
end

% Average across all left (and right) trials
for i = 1:length(Q)
    mean_proj_Q.left{i} = mean(cat(3, proj_Q{i}.left{:}), 3);
    mean_proj_Q.right{i} = mean(cat(3, proj_Q{i}.right{:}), 3);
end

dist_mat = zeros(length(Q));
for sr_i = 1:length(Q)
    % Exclude the data from the sessions we try to predict
    for ex_i = 1:length(Q)
        if sr_i ~= ex_i
            % Exclude the right trials (padded with zeros) for the target subject
            ex_mean_proj_Q = mean_proj_Q;
            ex_mean_proj_Q.right{ex_i} = zeros(size(mean_proj_Q.right{ex_i}));
            % Perform hyperalignment with excluded data
            [ex_aligned_left, ex_aligned_right] = get_aligned_left_right(ex_mean_proj_Q);
            % Perform hyperalignment with original data (to get ground truth)
            [aligned_left, aligned_right] = get_aligned_left_right(mean_proj_Q);

            aligned_source = ex_aligned_left;
            aligned_target = ex_aligned_right;
            true_aligned_target = aligned_right;

            % Find the transform for source subject from left to right in the common space.
            [~, ~, M{sr_i}] = procrustes(aligned_target{sr_i}', aligned_source{sr_i}');
            predicted = cellfun(@(x) p_transform(M{sr_i}, x), aligned_source, 'UniformOutput', false);
            % Compare with its original aligned right
            dist_mat(sr_i, ex_i) = calculate_dist(predicted{ex_i}, true_aligned_target{ex_i});
        else
            dist_mat(sr_i, ex_i) = NaN;
        end
    end
end
