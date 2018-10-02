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
Q = {Q_42, Q_44, Q_64};

% Make all right trials identical to left ones as a control
for i = 1:length(Q)
    for j = 1:length(Q{i}.left)
        Q{i}.right{j}.data = Q{i}.left{j}.data;
    end
end

% PCA
NumComponents = 10;
for i = 1:length(Q)
    proj_Q{i} = perform_pca(Q{i}, NumComponents);
end

% Average across all left (and right) trials
for i = 1:length(proj_Q)
    mean_proj_Q.left{i} = mean(cat(3, proj_Q{i}.left{:}), 3);
    mean_proj_Q.right{i} = mean(cat(3, proj_Q{i}.right{:}), 3);
end

% Hyperalignment
for i = 1:3
    hyper_input{i} = [mean_proj_Q.left{i}, mean_proj_Q.right{i}];
end
[aligned, transforms] = hyperalign(hyper_input{1:3});

t_len = size(mean_proj_Q.left{1}, 2);
aligned_left = cellfun(@(x) x(:, 1:t_len), aligned, 'UniformOutput', false);
aligned_right = cellfun(@(x) x(:, t_len+1:end), aligned, 'UniformOutput', false);

% Find the transform for first subject from left to right in the common space.
[~, ~, M_42] = procrustes(aligned_right{1}', aligned_left{1}');
predicted_R = cellfun(@(x) p_transform(M_42, x), aligned_left, 'UniformOutput', false);

% Compare with its original aligned right
for i = 1:length(predicted_R)
    dist{i} = calculate_dist(predicted_R{i}, aligned_right{i});
    dist_LR{i} = calculate_dist(aligned_left{i}, aligned_right{i});
end

% Shuffle aligned Q matrix
rand_dists  = cell(1, 3);
for i = 1:100
% %     Shuffling the mean projected matrix (right)
%     for j = 1:length(aligned_right)
%         shuffle_indices{j} = randperm(NumComponents);
%         shuffled_right{j} = mean_proj_Q.right{j}(shuffle_indices{j}, :);
%         s_aligned{j} = p_transform(transforms{j}, [mean_proj_Q.left{j}, shuffled_right{j}]);
%         rand_dists{j} = [rand_dists{j}, calculate_dist(predicted_R{j}, s_aligned{j}(:, t_len+1:end))];
%     end

    s_Q = Q;
    for j = 1:length(Q)
        shuffle_indices{j} = randperm(size(Q{j}.right{j}.data, 1));
        for k = 1:length(Q{j}.right)
            s_Q{j}.right{k}.data = Q{j}.right{k}.data(shuffle_indices{j}, :);
        end
    end

    % shift-shuffling the mean projected matrix (right)
    % for j = 1:length(aligned_right)
    %     win_len = size(aligned_right{j}, 2);
    %     for k = 1:NumComponents
    %         shuffle_indices = shift_shuffle(win_len);
    %         shuffled_right{j}(k, :) = mean_proj_Q.right{j}(k, shuffle_indices);
    %     end
    %     s_aligned_right{j} = p_transform(transforms_right{j}, shuffled_right{j});
    %     rand_dists{j} = [rand_dists{j}, calculate_dist(predicted_R{j}, s_aligned_right{j})];
    % end

    % PCA
    for p_i = 1:length(Q)
        s_proj_Q{p_i} = perform_pca(s_Q{p_i}, NumComponents);
    end

    % Average across all left (and right) trials
    for a_i = 1:length(s_proj_Q)
        mean_s_proj_Q.left{a_i} = mean(cat(3, s_proj_Q{a_i}.left{:}), 3);
        mean_s_proj_Q.right{a_i} = mean(cat(3, s_proj_Q{a_i}.right{:}), 3);
    end

%     Perform hyperalignment on independently shuffled right Q matrix
    for h_i = 1:3
        s_hyper_input{h_i} = [mean_s_proj_Q.left{h_i}, mean_s_proj_Q.right{h_i}];
    end
    [s_aligned, s_transforms] = hyperalign(s_hyper_input{1:3});
    s_aligned_left = cellfun(@(x) x(:, 1:t_len), s_aligned, 'UniformOutput', false);
    s_aligned_right = cellfun(@(x) x(:, t_len+1:end), s_aligned, 'UniformOutput', false);

%     Find the transform for first subject from left to right in the common space.
    [~, ~, shuffle_M_42] = procrustes(s_aligned_right{1}', s_aligned_left{1}');
    s_predicted_R = cellfun(@(x) p_transform(shuffle_M_42, x), s_aligned_left, 'UniformOutput', false);

    for d_i = 1:length(s_aligned_right)
        rand_dists{d_i} = [rand_dists{d_i}, calculate_dist(s_predicted_R{d_i}, s_aligned_right{d_i})];
    end
end

% Plot shuffle distance histogram and true distance (by shuffling Q matrix)
subj_list = [42, 44, 64];
for i = 1:length(subj_list)
    subplot(3, 1, i)
    histogram(rand_dists{i})
    line([dist{i}, dist{i}], ylim, 'LineWidth', 2, 'Color', 'r')
%     line([dist_LR{i}, dist_LR{i}], ylim, 'LineWidth', 2, 'Color', 'g')
    title(sprintf('Subject %d: Distance betweeen using M42* and its own aligned right trials', subj_list(i)))
end
