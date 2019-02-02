% Get processed data
cfg_data = [];
cfg_data.only_use_cp = 1;
TC = prepare_all_TC(cfg_data);

% PCA
NumComponents = 10;
for tc_i = 1:length(TC)
    proj_TC{tc_i} = perform_pca(TC{tc_i}, NumComponents);
end

% Hyperalignment
[aligned_left, aligned_right] = get_aligned_left_right(proj_TC);

actual_dists_mat = zeros(length(TC));
id_dists_mat = zeros(length(TC));

aligned_source = aligned_left;
aligned_target = aligned_right;
for sr_i = 1:length(TC)
    % Find the transform for source subject from left to right in the common space.
    [~, ~, M{sr_i}] = procrustes(aligned_target{sr_i}', aligned_source{sr_i}');
    predicted = cellfun(@(x) p_transform(M{sr_i}, x), aligned_source, 'UniformOutput', false);

    % Compare with its original aligned right
    for tar_i = 1:length(predicted)
        actual_dists_mat(sr_i, tar_i) = calculate_dist(predicted{tar_i}, aligned_target{tar_i});
        id_dists_mat(sr_i, tar_i) = calculate_dist(aligned_source{tar_i}, aligned_target{tar_i});
    end
end

% Shuffle TC matrix
n_shuffles = 1000;
sf_dists_mat  = zeros(length(TC), length(TC), n_shuffles);
for i = 1:n_shuffles
    % for j = 1:length(aligned_right)
    %     shuffle_indices{j} = randperm(NumComponents);
    %     shuffled_right{j} = proj_TC{j}.right(shuffle_indices{j}, :);
    %     s_aligned{j} = p_transform(transforms{j}, [proj_TC{j}.left, shuffled_right{j}]);
    %     rand_dists{j} = [rand_dists{j}, calculate_dist(predicted_R{j}, s_aligned{j}(:, w_len+1:end))];
    % end

    s_TC = TC;
    for j = 1:length(TC)
        shuffle_indices{j} = randperm(size(TC{j}.right, 1));
        s_TC{j}.right = TC{j}.right(shuffle_indices{j}, :);
    end

    % PCA
    for p_i = 1:length(TC)
        s_proj_TC{p_i} = perform_pca(s_TC{p_i}, NumComponents);
    end

    % Hyperalignment
    [s_aligned_left, s_aligned_right] = get_aligned_left_right(s_proj_TC);

    s_aligned_source = s_aligned_left;
    s_aligned_target = s_aligned_right;
    for s_sr_i = 1:length(TC)
        [~, ~, shuffle_M{s_sr_i}] = procrustes(s_aligned_target{s_sr_i}', s_aligned_source{s_sr_i}');
        s_predicted = cellfun(@(x) p_transform(shuffle_M{s_sr_i}, x), s_aligned_source, 'UniformOutput', false);

        for s_tar_i = 1:length(s_predicted)
            sf_dists_mat(s_sr_i, s_tar_i, i) = calculate_dist(s_predicted{s_tar_i}, s_aligned_target{s_tar_i});
        end
    end
end
