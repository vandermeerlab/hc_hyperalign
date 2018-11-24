tic;
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
dist_LR_mat = zeros(length(Q));

for sr_i = 1:length(Q)
%     ex_mean_proj_Q = mean_proj_Q;
%     ex_mean_proj_Q.right{ex_i} = zeros(size(mean_proj_Q.right{ex_i}));
    % Exclude the data from the sessions we try to predict, i.e padding the right trials with zeros for the target subject
    for ex_i = 1:length(Q)
        if sr_i ~= ex_i
            ex_Q = Q;
            for rt_i = 1:length(Q{ex_i}.right)
                ex_Q{ex_i}.right{rt_i}.data = zeros(size(Q{ex_i}.right{rt_i}.data));
            end
            % PCA
            ex_proj_Q = proj_Q;
            ex_proj_Q{ex_i} = perform_pca(ex_Q{ex_i}, NumComponents);

            % Average across left (and right) trials
            ex_mean_proj_Q = mean_proj_Q;
            ex_mean_proj_Q.left{ex_i} = mean(cat(3, ex_proj_Q{ex_i}.left{:}), 3);
            ex_mean_proj_Q.right{ex_i} = mean(cat(3, ex_proj_Q{ex_i}.right{:}), 3);

            % Perform hyperalignment with excluded data
            [ex_aligned_left, ex_aligned_right, ex_transforms] = get_aligned_left_right(ex_mean_proj_Q);
            % Perform hyperalignment with original data (to get ground truth)
            [aligned_left, aligned_right, transforms] = get_aligned_left_right(mean_proj_Q);
            % putative_traj = p_transform(ex_transforms{ex_i}, [mean_proj_Q.left{ex_i}, mean_proj_Q.right{ex_i}]);

            aligned_source = ex_aligned_left;
            aligned_target = ex_aligned_right;
            true_aligned_source = aligned_left;
            true_aligned_target = aligned_right;
            % true_aligned_target = putative_traj(:, 49:end);

            % Find the transform for source subject from left to right in the common space.
            [~, ~, M{sr_i}] = procrustes(aligned_target{sr_i}', aligned_source{sr_i}');
            predicted = p_transform(M{sr_i}, aligned_source{ex_i});
            project_back = inv_p_transform(ex_transforms{ex_i}, [aligned_source{ex_i}, predicted]);           

            % Compare with its original aligned right
            dist_mat(sr_i, ex_i) = calculate_dist(predicted, true_aligned_target{ex_i});
            dist_LR_mat(sr_i, ex_i) = calculate_dist(true_aligned_source{ex_i}, true_aligned_target{ex_i});
        else
            dist_mat(sr_i, ex_i) = NaN;
            dist_LR_mat(sr_i, ex_i) = NaN;
        end
    end
end

% Shuffle aligned Q matrix
rand_dists_mat  = cell(length(Q), length(Q));
for i = 1:100
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

    % Perform hyperalignment on independently shuffled right Q matrix
    for s_sr_i = 1:length(Q)
        % Exclude the data from the sessions we try to predict, i.e padding the right trials with zeros for the target subject
        for s_ex_i = 1:length(Q)
            if s_sr_i ~= s_ex_i
                ex_s_Q = s_Q;
                for rt_i = 1:length(Q{ex_i}.right)
                    ex_s_Q{ex_i}.right{rt_i}.data = zeros(size(Q{ex_i}.right{rt_i}.data));
                end
                ex_s_proj_Q = s_proj_Q;
                ex_s_proj_Q{s_ex_i} = perform_pca(ex_s_Q{s_ex_i}, NumComponents);

                ex_mean_s_proj_Q = mean_s_proj_Q;
                ex_mean_s_proj_Q.left{s_ex_i} = mean(cat(3, ex_s_proj_Q{s_ex_i}.left{:}), 3);
                ex_mean_s_proj_Q.right{s_ex_i} = mean(cat(3, ex_s_proj_Q{s_ex_i}.right{:}), 3);

                % Exclude the right trials (padded with zeros) for the target subject
                % ex_mean_s_proj_Q = mean_s_proj_Q;
                % ex_mean_s_proj_Q.right{s_ex_i} = zeros(size(mean_s_proj_Q.right{s_ex_i}));
                % Perform hyperalignment with excluded data
                [ex_s_aligned_left, ex_s_aligned_right, ex_s_transforms] = get_aligned_left_right(ex_mean_s_proj_Q);
                % Perform hyperalignment with original data (to get ground truth)
                [s_aligned_left, s_aligned_right, s_transforms] = get_aligned_left_right(mean_s_proj_Q);
                % s_putative_traj = p_transform(ex_transforms{s_ex_i}, [mean_s_proj_Q.left{s_ex_i}, mean_s_proj_Q.right{s_ex_i}]);

                s_aligned_source = ex_s_aligned_left;
                s_aligned_target = ex_s_aligned_right;
                s_true_aligned_target = s_aligned_right;
                % s_true_aligned_target = s_putative_traj(:, 49:end);

                % Find the transform for source subject from left to right in the common space.
                [~, ~, shuffle_M{s_sr_i}] = procrustes(s_aligned_target{s_sr_i}', s_aligned_source{s_sr_i}');
                s_predicted = p_transform(shuffle_M{s_sr_i}, s_aligned_source{s_ex_i});
                % Compare with its original aligned right
                rand_dists_mat{s_sr_i, s_ex_i} = [rand_dists_mat{s_sr_i, s_ex_i}, calculate_dist(s_predicted,s_true_aligned_target{s_ex_i})];
            else
                rand_dists_mat{s_sr_i, s_ex_i} = NaN;
            end
        end
    end
end
toc;