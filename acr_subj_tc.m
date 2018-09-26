% Get processed data
TC_42 = get_tuning_curve('/R042-2013-08-18/');
TC_44 = get_tuning_curve('/R044-2013-12-21/');
TC_64 = get_tuning_curve('/R064-2015-04-20/');

% PCA
NumComponents = 10;
proj_TC{1} = perform_pca(TC_42, NumComponents);
proj_TC{2} = perform_pca(TC_44, NumComponents);
proj_TC{3} = perform_pca(TC_64, NumComponents);

% Hyperalignment
all_proj_left = cellfun(@(x) (x.left), proj_TC, 'UniformOutput', false);
all_proj_right = cellfun(@(x) (x.right), proj_TC, 'UniformOutput', false);

[aligned, transforms] = hyperalign(all_proj_left{1:3}, all_proj_right{1:3});

aligned_left = aligned(1:3);
transforms_left = transforms(1:3);

aligned_right = aligned(4:6);
transforms_right = transforms(4:6);

% Find the transform for first subject from left to right in the common space.
[~, ~, M{1}] = procrustes(aligned_right{1}', aligned_left{1}');
aligned_LR = cellfun(@(x) p_transform(M{1}, x), aligned_left, 'UniformOutput', false);

% Compare with its original aligned right
for i = 1:length(aligned_LR)
    dist{i} = calculate_dist(aligned_LR{i}, aligned_right{i});
end

% Shuffle aligned TC matrix
rand_dists  = cell(1, 3);
for i = 1:100
    for j = 1:length(aligned_right)
        shuffle_indices{j} = randperm(NumComponents);
        shuffled_right{j} = all_proj_right{j}(shuffle_indices{j}, :);
        s_aligned_right{j} = p_transform(transforms_right{j}, shuffled_right{j});
        rand_dists{j} = [rand_dists{j}, calculate_dist(aligned_LR{j}, s_aligned_right{j})];
    end
end

% Plot shuffle distance histogram and true distance (by shuffling TC matrix)
subj_list = [42, 44, 64];
for i = 1:length(subj_list)
    subplot(3, 1, i)
    histogram(rand_dists{i})
    line([dist{i}, dist{i}], ylim, 'LineWidth', 2, 'Color', 'r');
    title(sprintf('Subject %d: Distance betweeen using transformation of 42 and its own aligned right trials', subj_list(i)))
end
