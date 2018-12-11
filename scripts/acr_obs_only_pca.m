% % Get processed data
% cfg_data.paperSessions = 1;
% data_paths = getTmazeDataPath(cfg_data);
% restrictionLabels = get_restriction_types(data_paths);

% cfg.use_matched_trials = 1;
% Q = cell(1, length(data_paths));
% for p_i = 1:length(data_paths)
%     Q{p_i} = get_processed_Q(cfg, data_paths{p_i});
% end

% % Average across all left (and right) trials
% for i = 1:length(Q)
%     Q_left = cellfun(@(x) x.data, Q{i}.left, 'UniformOutput', false);
%     Q_right = cellfun(@(x) x.data, Q{i}.right, 'UniformOutput', false);
%     mean_Q{i}.left = mean(cat(3, Q_left{:}), 3);
%     mean_Q{i}.right = mean(cat(3, Q_right{:}), 3);
% end

% % PCA
% NumComponents = 10;
% for i = 1:length(Q)
%     [mean_proj_Q{i}, eigvecs{i}] = perform_pca(mean_Q{i}, NumComponents);
% end

% dist_mat = zeros(length(Q));
% dist_LR_mat = zeros(length(Q));

% aligned_source = cellfun(@(x) x.left, mean_proj_Q, 'UniformOutput', false);
% aligned_target = cellfun(@(x) x.right, mean_proj_Q, 'UniformOutput', false);
% for sr_i = 1:length(Q)
%     % Find the transform for source subject from left to right in the PCA space.
%     [~, ~, M{sr_i}] = procrustes(aligned_target{sr_i}', aligned_source{sr_i}');
%     predicted = cellfun(@(x) p_transform(M{sr_i}, x), aligned_source, 'UniformOutput', false);
%     for tar_i = 1:length(Q)
%         % Project prediction and identity mapping back to Q space.
%         project_back_Q_right = eigvecs{tar_i} * predicted{tar_i};
%         project_back_Q_id_right = eigvecs{tar_i} * aligned_source{tar_i};

%         % Compare with its original right Q
%         ground_truth_Q = mean_Q{tar_i}.right;
%         dist_mat(sr_i, tar_i) = calculate_dist(project_back_Q_right, ground_truth_Q);
%         dist_LR_mat(sr_i, tar_i) = calculate_dist(project_back_Q_id_right, ground_truth_Q);
%     end
% end

% % Shuffle aligned Q matrix
% rand_dists_mat = cell(length(Q), length(Q));
% rand_dists_LR_mat = cell(length(Q), length(Q));
% predicted_id_mat = zeros(length(Q));
% for i = 1:1000
%     mean_s_Q = mean_Q;
%     for j = 1:length(Q)
%         shuffle_indices{j} = randperm(size(Q{j}.right{1}.data, 1));
%         mean_s_Q{j}.right = mean_Q{j}.right(shuffle_indices{j}, :);
%     end

%      % PCA
%     for p_i = 1:length(Q)
%         [mean_s_proj_Q{p_i}, s_eigvecs{p_i}] = perform_pca(mean_s_Q{p_i}, NumComponents);
%     end

%     s_aligned_source = cellfun(@(x) x.left, mean_s_proj_Q, 'UniformOutput', false);
%     s_aligned_target = cellfun(@(x) x.right, mean_s_proj_Q, 'UniformOutput', false);
%     for s_sr_i = 1:length(Q)
%         [~, ~, shuffle_M{s_sr_i}] = procrustes(s_aligned_target{s_sr_i}', s_aligned_source{s_sr_i}');
%         s_predicted = cellfun(@(x) p_transform(shuffle_M{s_sr_i}, x), s_aligned_source, 'UniformOutput', false);
%         for s_tar_i = 1:length(Q)
%             % Project prediction and identity mapping back to Q space.
%             s_project_back_Q_right = s_eigvecs{s_tar_i} * s_predicted{s_tar_i};
%             s_project_back_Q_id_right = s_eigvecs{s_tar_i} * s_aligned_source{s_tar_i};

%             % Compare with its shuffled right Q
%             s_ground_truth_Q = mean_s_Q{s_tar_i}.right;
%             s_predicted_dist = calculate_dist(s_project_back_Q_right, s_ground_truth_Q);
%             s_id_dist = calculate_dist(s_project_back_Q_id_right, s_ground_truth_Q);
%             rand_dists_mat{s_sr_i, s_tar_i} = [rand_dists_mat{s_sr_i, s_tar_i}, s_predicted_dist];
%             rand_dists_LR_mat{s_sr_i, s_tar_i} = [rand_dists_LR_mat{s_sr_i, s_tar_i}, s_id_dist];
%             if s_predicted_dist < s_id_dist
%                 predicted_id_mat(s_sr_i, s_tar_i) = predicted_id_mat(s_sr_i, s_tar_i) + 1;
%             end
%         end
%     end
% end

% Get processed data
cfg_data.paperSessions = 1;
data_paths = getTmazeDataPath(cfg_data);
restrictionLabels = get_restriction_types(data_paths);

cfg.use_matched_trials = 1;
Q = cell(1, length(data_paths));
for p_i = 1:length(data_paths)
    Q{p_i} = get_processed_Q(cfg, data_paths{p_i});
end

% Average across all left (and right) trials
for i = 1:length(Q)
    Q_left = cellfun(@(x) x.data, Q{i}.left, 'UniformOutput', false);
    Q_right = cellfun(@(x) x.data, Q{i}.right, 'UniformOutput', false);
    mean_Q{i}.left = mean(cat(3, Q_left{:}), 3);
    mean_Q{i}.right =  mean(cat(3, Q_right{:}), 3);
end

actual_dists_mat  = cell(length(Q), length(Q));
sf_dists_mat  = cell(length(Q), length(Q));
id_dists_mat  = cell(length(Q), length(Q));
actual_sf_mat = zeros(length(Q));
actual_id_mat = zeros(length(Q));

for i = 1:1000
    % Shuffle right Q matrices
    mean_s_Q = mean_Q;
    for s_i = 1:length(Q)
        shuffle_indices{s_i} = randperm(size(Q{s_i}.right{1}.data, 1));
        mean_s_Q{s_i}.right = mean_Q{s_i}.right(shuffle_indices{s_i}, :);
    end

     % PCA
     NumComponents = 10;
    for p_i = 1:length(Q)
        % Concatenate Q matrix across left and right trials and perform PCA on it.
        pca_input = [mean_Q{p_i}.left, mean_Q{p_i}.right, mean_s_Q{p_i}.right];
        [eigvecs{p_i}] = pca_egvecs(pca_input, NumComponents);
        %  project all other trials (both left and right trials) to the same dimension
        aligned_source{p_i} = pca_project(mean_Q{p_i}.left, eigvecs{p_i});
        aligned_target{p_i} = pca_project(mean_Q{p_i}.right, eigvecs{p_i});
        s_aligned_target{p_i} = pca_project(mean_s_Q{p_i}.right, eigvecs{p_i});
    end

    for sr_i = 1:length(Q)
        [~, ~, M{sr_i}] = procrustes(aligned_target{sr_i}', aligned_source{sr_i}');
        predicted = cellfun(@(x) p_transform(M{sr_i}, x), aligned_source, 'UniformOutput', false);

        [~, ~, sf_M{sr_i}] = procrustes(s_aligned_target{sr_i}', aligned_source{sr_i}');
        s_predicted = cellfun(@(x) p_transform(sf_M{sr_i}, x), aligned_source, 'UniformOutput', false);

        for tar_i = 1:length(Q)
            % Project prediction and identity mapping back to Q space.
            project_back_Q_right = eigvecs{tar_i} * predicted{tar_i};
            s_project_back_Q_right = eigvecs{tar_i} * s_predicted{tar_i};
            project_back_Q_id_right = eigvecs{tar_i} * aligned_source{tar_i};

            ground_truth_Q = mean_Q{tar_i}.right;

            actual_dist = calculate_dist(project_back_Q_right, ground_truth_Q);
            shuffled_dist = calculate_dist(s_project_back_Q_right, ground_truth_Q);
            id_dist = calculate_dist(project_back_Q_id_right, ground_truth_Q);

            actual_dists_mat{sr_i, tar_i} = [actual_dists_mat{sr_i, tar_i}, actual_dist];
            sf_dists_mat{sr_i, tar_i} = [sf_dists_mat{sr_i, tar_i}, shuffled_dist];
            id_dists_mat{sr_i, tar_i} = [id_dists_mat{sr_i, tar_i}, id_dist];

            if actual_dist < shuffled_dist
                actual_sf_mat(sr_i, tar_i) = actual_sf_mat(sr_i, tar_i) + 1;
            end
            if actual_dist < id_dist
                actual_id_mat(sr_i, tar_i) = actual_id_mat(sr_i, tar_i) + 1;
            end
        end
    end
end
