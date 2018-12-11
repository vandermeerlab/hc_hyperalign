% Get processed data
cfg_data.paperSessions = 1;
data_paths = getTmazeDataPath(cfg_data);
restrictionLabels = get_restriction_types(data_paths);

cfg.use_matched_trials = 1;
TC = cell(1, length(data_paths));
for p_i = 1:length(data_paths)
    TC{p_i} = get_tuning_curve(cfg, data_paths{p_i});
end

only_use_cp = 1;
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

sf_dists_mat  = cell(length(TC), 1);
id_dists_mat  = cell(length(TC), 1);
sf_id_mat = zeros(length(TC), 1);

for i = 1:1000
    % Shuffle right TC matrix
    s_TC = TC;
    for j = 1:length(TC)
        shuffle_indices{j} = randperm(size(TC{j}.right.tc, 1));
        s_TC{j}.right.tc = TC{j}.right.tc(shuffle_indices{j}, :);
    end

    % Project [L, R'] to PCA space.
     NumComponents = 10;
    for p_i = 1:length(TC)
        % Concatenate TC matrix across left and right trials and perform PCA on it.
        pca_input = [TC{p_i}.left.tc, s_TC{p_i}.right.tc];
        [eigvecs{p_i}] = pca_egvecs(pca_input, NumComponents);
        %  project all other trials (both left and right trials) to the same dimension
        proj_TC{p_i}.left = pca_project(TC{p_i}.left.tc, eigvecs{p_i});
        proj_TC{p_i}.s_right = pca_project(s_TC{p_i}.right.tc, eigvecs{p_i});
    end

    % % Perform hyperalignment on concatenated [L, shuffled_R] in PCA
    % for h_i = 1:length(TC)
    %     hyper_input{h_i} = [proj_TC{h_i}.left, proj_TC{h_i}.s_right];
    % end
    % [aligned, transforms] = hyperalign(hyper_input{:});
    % w_len = size(proj_TC{1}.left, 2);
    % aligned_left = cellfun(@(x) x(:, 1:w_len), aligned, 'UniformOutput', false);
    % s_aligned_right = cellfun(@(x) x(:, w_len+1:end), aligned, 'UniformOutput', false);

    aligned_source = cellfun(@(x) x.left, proj_TC, 'UniformOutput', false);
    s_aligned_target = cellfun(@(x) x.s_right, proj_TC, 'UniformOutput', false);
    for sr_i = 1:length(TC)
        % Estimate M' from L to R'.
        [~, ~, sf_M{sr_i}] = procrustes(s_aligned_target{sr_i}', aligned_source{sr_i}');
        % Apply M' to L to predict.
        s_predicted = p_transform(sf_M{sr_i}, aligned_source{sr_i});
        % % Project back to PCA space
        % padding = zeros(size(aligned_source{sr_i}));
        % s_project_back_pca = inv_p_transform(transforms{sr_i}, [padding, s_predicted]);
        % % Estimate M only using L (identity mapping).
        % project_back_pca_id = inv_p_transform(transforms{sr_i}, [padding, aligned_source{sr_i}]);
        % % Project back to TC space.
        % s_project_back_TC_right = eigvecs{sr_i} * s_project_back_pca(:, w_len+1:end);
        % project_back_TC_id_right = eigvecs{sr_i} * project_back_pca_id(:, w_len+1:end);

        s_project_back_TC_right = eigvecs{sr_i} * s_predicted;
        project_back_TC_id_right = eigvecs{sr_i} * aligned_source{sr_i};
        % Compare prediction from M ro M' is better
        ground_truth_TC = TC{sr_i}.right.tc;
        shuffled_dist = calculate_dist(s_project_back_TC_right, ground_truth_TC);
        id_dist = calculate_dist(project_back_TC_id_right, ground_truth_TC);

        sf_dists_mat{sr_i} = [sf_dists_mat{sr_i}, shuffled_dist];
        id_dists_mat{sr_i} = [id_dists_mat{sr_i}, id_dist];
        if id_dist < shuffled_dist
            sf_id_mat(sr_i) = sf_id_mat(sr_i) + 1;
        end
    end
end
