% Common binning and windowing configurations.
cfg = [];
cfg.dt = 0.05;
cfg.smooth = 'gauss';
cfg.gausswin_size = 1;
cfg.gausswin_sd = 0.02;

% Get processed data
cfg_in.paperSessions = 1;
data_paths = getTmazeDataPath(cfg_in);

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

% Hyperalignment
for i = 1:length(Q)
    hyper_input{i} = [mean_proj_Q.left{i}, mean_proj_Q.right{i}];
end
[aligned, transforms] = hyperalign(hyper_input{:});

t_len = size(mean_proj_Q.left{1}, 2);
aligned_left = cellfun(@(x) x(:, 1:t_len), aligned, 'UniformOutput', false);
aligned_right = cellfun(@(x) x(:, t_len+1:end), aligned, 'UniformOutput', false);

dist_mat = zeros(length(Q));
dist_LR_mat = zeros(length(Q));
for source_i = 1:length(Q)
    % Find the transform for source subject from left to right in the common space.
    [~, ~, M{source_i}] = procrustes(aligned_right{source_i}', aligned_left{source_i}');
    predicted_R = cellfun(@(x) p_transform(M{source_i}, x), aligned_left, 'UniformOutput', false);

    % Compare with its original aligned right
    for i = 1:length(predicted_R)
        dist_mat(source_i, i) = calculate_dist(predicted_R{i}, aligned_right{i});
        dist_LR_mat(source_i, i) = calculate_dist(aligned_left{i}, aligned_right{i});
    end
end

% Shuffle aligned Q matrix
rand_dists_mat  = cell(length(Q), length(Q));
for i = 1:1000
% %     Shuffling the mean projected matrix (right)
%     for j = 1:length(aligned_right)
%         shuffle_indices{j} = randperm(NumComponents);
%         shuffled_right{j} = mean_proj_Q.right{j}(shuffle_indices{j}, :);
%         s_aligned{j} = p_transform(transforms{j}, [mean_proj_Q.left{j}, shuffled_right{j}]);
%         rand_dists{j} = [rand_dists{j}, calculate_dist(predicted_R{j}, s_aligned{j}(:, t_len+1:end))];
%     end

    s_Q = Q;
    for j = 1:length(Q)
        shuffle_indices{j} = randperm(size(Q{j}.right{1}.data, 1));
        for k = 1:length(Q{j}.right)
            s_Q{j}.right{k}.data = Q{j}.right{k}.data(shuffle_indices{j}, :);
        end
    end

    % PCA
    for p_i = 1:length(Q)
        s_proj_Q{p_i} = perform_pca(s_Q{p_i}, NumComponents);
    end

    % Average across all left (and right) trials
    for a_i = 1:length(Q)
        mean_s_proj_Q.left{a_i} = mean(cat(3, s_proj_Q{a_i}.left{:}), 3);
        mean_s_proj_Q.right{a_i} = mean(cat(3, s_proj_Q{a_i}.right{:}), 3);
    end

%     Perform hyperalignment on independently shuffled right Q matrix
    for h_i = 1:length(Q)
        s_hyper_input{h_i} = [mean_s_proj_Q.left{h_i}, mean_s_proj_Q.right{h_i}];
    end
    [s_aligned, s_transforms] = hyperalign(s_hyper_input{:});
    s_aligned_left = cellfun(@(x) x(:, 1:t_len), s_aligned, 'UniformOutput', false);
    s_aligned_right = cellfun(@(x) x(:, t_len+1:end), s_aligned, 'UniformOutput', false);

    for s_source_id = 1:length(Q)
        [~, ~, shuffle_M{s_source_id}] = procrustes(s_aligned_right{s_source_id}', s_aligned_left{s_source_id}');
        s_predicted_R = cellfun(@(x) p_transform(shuffle_M{s_source_id}, x), s_aligned_left, 'UniformOutput', false);

        for d_i = 1:length(s_aligned_right)
            rand_dists_mat{s_source_id, d_i} = [rand_dists_mat{s_source_id, d_i}, calculate_dist(s_predicted_R{d_i}, s_aligned_right{d_i})];
        end
    end
end

zscore_mat = zeros(length(Q));
percent_mat = zeros(length(Q));
for mat_i = 1:numel(zscore_mat)
    zs = zscore([rand_dists_mat{mat_i}, dist_mat(mat_i)]);
    zscore_mat(mat_i) = zs(end);
    percent_mat(mat_i) = get_percentile(dist_mat(mat_i), rand_dists_mat{mat_i});
end

imagesc(zscore_mat);
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
title('Z-score of distances including within subjects')

imagesc(percent_mat);
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
title('Percentile of distances including within subjects')

out_zscore_mat = set_withsubj_nan(zscore_mat);
imagesc(out_zscore_mat,'AlphaData', ~isnan(out_zscore_mat));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
title('Z-score of distances excluding within subjects')

out_percent_mat = set_withsubj_nan(percent_mat);
imagesc(out_percent_mat,'AlphaData', ~isnan(out_percent_mat));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
title('Percentile of distances excluding within subjects')

% % Plot shuffle distance histogram and true distance (by shuffling Q matrix)
% for i = 1:length(Q)
%     subplot(length(Q), 1, i)
%     histogram(rand_dists{i})
%     line([dist{i}, dist{i}], ylim, 'LineWidth', 2, 'Color', 'r')
%     line([dist_LR{i}, dist_LR{i}], ylim, 'LineWidth', 2, 'Color', 'g')
%     title('Distance betweeen using M* and its own aligned right trials')
% end
