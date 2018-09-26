% Common binning and windowing configurations.
cfg = [];
cfg.dt = 0.05;
cfg.smooth = 'gauss';
cfg.gausswin_size = 1;
cfg.gausswin_sd = 0.02;

% Get processed data
Q_42 = get_processed_Q(cfg, '/R042-2013-08-18/');
Q_44 = get_processed_Q(cfg, '/R044-2013-12-21/');
Q_64 = get_processed_Q(cfg, '/R064-2015-04-20/');

% PCA
NumComponents = 10;
proj_Q{1} = perform_pca(Q_42, NumComponents);
proj_Q{2} = perform_pca(Q_44, NumComponents);
proj_Q{3} = perform_pca(Q_64, NumComponents);

% Average across all left (and right) trials
for i = 1:length(proj_Q)
    mean_proj_Q.left{i} = mean(cat(3, proj_Q{i}.left{:}), 3);
    mean_proj_Q.right{i} = mean(cat(3, proj_Q{i}.right{:}), 3);
end

% Hyperalignment
[aligned, transforms] = hyperalign(mean_proj_Q.left{1:3}, mean_proj_Q.right{1:3});

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

% Shuffle aligned Q matrix
rand_dists  = cell(1, 3);
for i = 1:100
    for j = 1:length(aligned_right)
        shuffle_indices{j} = randperm(NumComponents);
        shuffled_right{j} = mean_proj_Q.right{j}(shuffle_indices{j}, :);
        s_aligned_right{j} = p_transform(transforms_right{j}, shuffled_right{j});
        rand_dists{j} = [rand_dists{j}, calculate_dist(aligned_LR{j}, s_aligned_right{j})];
    end
end

% Plot shuffle distance histogram and true distance (by shuffling Q matrix)
subj_list = [42, 44, 64];
for i = 1:length(subj_list)
    subplot(3, 1, i)
    histogram(rand_dists{i})
    line([dist{i}, dist{i}], ylim, 'LineWidth', 2, 'Color', 'r');
    title(sprintf('Subject %d: Distance betweeen using transformation of 42 and its own aligned right trials', subj_list(i)))
end
