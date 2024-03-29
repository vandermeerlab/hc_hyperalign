%% find data folders (If we need all of the data)
% fd_cfg = []; fd_cfg.userpath = '/Users/mac/Projects/mvdmlab/data';
% fd = getTmazeDataPath(fd_cfg);

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

% Calculate distance
for i = 1:length(aligned_left)
    dist{i} = calculate_dist(aligned_left{i}, aligned_right{i});
end

% Shuffle aligned TC
rand_dists  = cell(1, 3);
for i = 1:100
    for j = 1:length(aligned_right)
        shuffle_indices{j} = randperm(NumComponents);
        shuffled_right{j} = all_proj_right{j}(shuffle_indices{j}, :);
%         s_aligned_right{j} = p_transform(transforms_right{j}, shuffled_right{j});
%         rand_dists{j} = [rand_dists{j}, calculate_dist(aligned_left{j}, s_aligned_right{j})];
    end
%     for j = 1:length(aligned_right)
%         win_len = size(aligned_right{j}, 2);
%         for k = 1:NumComponents
%             shuffle_indices = shift_shuffle(win_len);
%             shuffled_right{j}(k, :) = all_proj_right{j}(k, shuffle_indices);
%         end
%         s_aligned_right{j} = p_transform(transforms_right{j}, shuffled_right{j});
%         rand_dists{j} = [rand_dists{j}, calculate_dist(aligned_left{j}, s_aligned_right{j})];
%     end
    % Perform hyperalignment on independently shuffled right Q matrix
    [s_aligned, ~] = hyperalign(all_proj_left{1:3}, shuffled_right{1:3});
    s_aligned_left = s_aligned(1:3);
    s_aligned_right = s_aligned(4:6);
    % Calculate distance
    for dist_i = 1:length(s_aligned_right)
        rand_dists{dist_i} = [rand_dists{dist_i}, calculate_dist(s_aligned_left{dist_i}, s_aligned_right{dist_i})];
    end
end

% Plot shuffle distance histogram and true distance (by shuffling TC matrix)
subj_list = [42, 44, 64];
for i = 1:length(subj_list)
    subplot(3, 1, i)
    histogram(rand_dists{i})
    line([dist{i}, dist{i}], ylim, 'LineWidth', 2, 'Color', 'r');
    title(sprintf('Subject %d: Distance after shuffling TC between left and right', subj_list(i)))
end
