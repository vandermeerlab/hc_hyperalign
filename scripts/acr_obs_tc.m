% Get processed data
cfg_data.paperSessions = 1;
data_paths = getTmazeDataPath(cfg_data);
restrictionLabels = get_restriction_types(data_paths);

cfg.use_matched_trials = 1;
TC = cell(1, length(data_paths));
for p_i = 1:length(data_paths)
    TC{p_i} = get_tuning_curve(cfg, data_paths{p_i});
end

only_use_cp = 0;
if only_use_cp
    % Find the time bin that the max of choice points among all trials correspond to
    left_cp_bins = cellfun(@(x) (x.left.cp_bin), TC);
    right_cp_bins = cellfun(@(x) (x.right.cp_bin), TC);
    max_cp_bin = max([left_cp_bins, right_cp_bins]);
    % Use data that is after the choice point
    for i = 1:length(TC)
        TC{i}.left.tc = TC{i}.left.tc(:, max_cp_bin+1:end);
        TC{i}.right.tc = TC{i}.right.tc(:, max_cp_bin+1:end);
    end
end

% PCA
NumComponents = 10;
for i = 1:length(TC)
    proj_TC{i} = perform_pca(TC{i}, NumComponents);
end

% Reformatting data structures
re_proj_TC.left = cellfun(@(x) x.left, proj_TC, 'UniformOutput', false);
re_proj_TC.right = cellfun(@(x) x.right, proj_TC, 'UniformOutput', false);

% Hyperalignment
[aligned_left, aligned_right] = get_aligned_left_right(re_proj_TC);

dist_mat = zeros(length(TC));
dist_LR_mat = zeros(length(TC));

aligned_source = aligned_left;
aligned_target = aligned_right;
for sr_i = 1:length(TC)
    % Find the transform for source subject from left to right in the common space.
    [~, ~, M{sr_i}] = procrustes(aligned_target{sr_i}', aligned_source{sr_i}');
    predicted = cellfun(@(x) p_transform(M{sr_i}, x), aligned_source, 'UniformOutput', false);

    % Compare with its original aligned right
    for i = 1:length(predicted)
        dist_mat(sr_i, i) = calculate_dist(predicted{i}, aligned_target{i});
        dist_LR_mat(sr_i, i) = calculate_dist(aligned_source{i}, aligned_target{i});
    end
end

% Shuffle TC matrix
rand_dists_mat  = cell(length(TC), length(TC));
for i = 1:1000
    % for j = 1:length(aligned_right)
    %     shuffle_indices{j} = randperm(NumComponents);
    %     shuffled_right{j} = proj_TC{j}.right(shuffle_indices{j}, :);
    %     s_aligned{j} = p_transform(transforms{j}, [proj_TC{j}.left, shuffled_right{j}]);
    %     rand_dists{j} = [rand_dists{j}, calculate_dist(predicted_R{j}, s_aligned{j}(:, w_len+1:end))];
    % end

    s_TC = TC;
    for j = 1:length(TC)
        shuffle_indices{j} = randperm(size(TC{j}.right.tc, 1));
        s_TC{j}.right.tc = TC{j}.right.tc(shuffle_indices{j}, :);
    end

    % PCA
    for p_i = 1:length(TC)
        s_proj_TC{p_i} = perform_pca(s_TC{p_i}, NumComponents);
    end

    % Reformatting data structures
    s_re_proj_TC.left = cellfun(@(x) x.left, s_proj_TC, 'UniformOutput', false);
    s_re_proj_TC.right = cellfun(@(x) x.right, s_proj_TC, 'UniformOutput', false);

    % Hyperalignment
    [s_aligned_left, s_aligned_right] = get_aligned_left_right(s_re_proj_TC);

    s_aligned_source = s_aligned_left;
    s_aligned_target = s_aligned_right;
    for s_sr_id = 1:length(TC)
        [~, ~, shuffle_M{s_sr_id}] = procrustes(s_aligned_target{s_sr_id}', s_aligned_source{s_sr_id}');
        s_predicted = cellfun(@(x) p_transform(shuffle_M{s_sr_id}, x), s_aligned_source, 'UniformOutput', false);

        for d_i = 1:length(s_predicted)
            rand_dists_mat{s_sr_id, d_i} = [rand_dists_mat{s_sr_id, d_i}, calculate_dist(s_predicted{d_i}, s_aligned_target{d_i})];
        end
    end
end
