% Get processed data
TC_42 = get_tuning_curve('/R042-2013-08-18/');
TC_44 = get_tuning_curve('/R044-2013-12-21/');
TC_64 = get_tuning_curve('/R064-2015-04-20/');
TC = {TC_42, TC_44, TC_64};

% PCA
NumComponents = 10;
for i = 1:length(TC)
    proj_TC{i} = perform_pca(TC{i}, NumComponents);
end

% Hyperalignment
for i = 1:3
    hyper_input{i} = [proj_TC{i}.left, proj_TC{i}.right];
end
[aligned, transforms] = hyperalign(hyper_input{1:3});

w_len = size(proj_TC{1}.left, 2);
aligned_left = cellfun(@(x) x(:, 1:w_len), aligned, 'UniformOutput', false);
aligned_right = cellfun(@(x) x(:, w_len+1:end), aligned, 'UniformOutput', false);

% Find the transform for first subject from left to right in the common space.
[~, ~, M_42] = procrustes(aligned_right{1}', aligned_left{1}');
predicted_R = cellfun(@(x) p_transform(M_42, x), aligned_left, 'UniformOutput', false);

% Compare with its original aligned right
for i = 1:length(predicted_R)
    dist{i} = calculate_dist(predicted_R{i}, aligned_right{i});
    dist_LR{i} = calculate_dist(aligned_left{i}, aligned_right{i});
end

% Shuffle TC matrix
rand_dists  = cell(1, 3);
for i = 1:100
    % for j = 1:length(aligned_right)
    %     shuffle_indices{j} = randperm(NumComponents);
    %     shuffled_right{j} = proj_TC{j}.right(shuffle_indices{j}, :);
    %     s_aligned{j} = p_transform(transforms{j}, [proj_TC{j}.left, shuffled_right{j}]);
    %     rand_dists{j} = [rand_dists{j}, calculate_dist(predicted_R{j}, s_aligned{j}(:, w_len+1:end))];
    % end

    s_TC = {TC_42, TC_44, TC_64};
    for j = 1:length(TC)
        shuffle_indices{j} = randperm(size(TC{j}.right.tc, 1));
        s_TC{j}.right.tc = TC{j}.right.tc(shuffle_indices{j}, :);
    end

    % PCA
    for p_i = 1:length(s_TC)
        s_proj_TC{p_i} = perform_pca(s_TC{p_i}, NumComponents);
    end

    % Hyperalignment
    for h_i = 1:3
        s_hyper_input{h_i} = [s_proj_TC{h_i}.left, s_proj_TC{h_i}.right];
    end
    [s_aligned, s_transforms] = hyperalign(s_hyper_input{1:3});
    s_aligned_left = cellfun(@(x) x(:, 1:w_len), s_aligned, 'UniformOutput', false);
    s_aligned_right = cellfun(@(x) x(:, w_len+1:end), s_aligned, 'UniformOutput', false);

%     Find the transform for first subject from left to right in the common space.
    [~, ~, shuffle_M_42] = procrustes(s_aligned_right{1}', s_aligned_left{1}');
    s_predicted_R = cellfun(@(x) p_transform(shuffle_M_42, x), s_aligned_left, 'UniformOutput', false);

    for d_i = 1:length(s_aligned_right)
        rand_dists{d_i} = [rand_dists{d_i}, calculate_dist(s_predicted_R{d_i}, s_aligned_right{d_i})];
    end
end

% Plot shuffle distance histogram and true distance (by shuffling TC matrix)
subj_list = [42, 44, 64];
for i = 1:length(subj_list)
    subplot(3, 1, i)
    histogram(rand_dists{i})
    line([dist{i}, dist{i}], ylim, 'LineWidth', 2, 'Color', 'r')
%     line([dist_LR{i}, dist_LR{i}], ylim, 'LineWidth', 2, 'Color', 'g')
    title(sprintf('Subject %d: Distance betweeen using M42 and its own aligned right trials', subj_list(i)))
end
