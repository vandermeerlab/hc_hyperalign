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

actual_dists_mat  = zeros(length(Q));
id_dists_mat  = zeros(length(Q));
sf_dists_mat  = cell(length(Q));
actual_sf_mat = zeros(length(Q));
id_sf_mat = zeros(length(Q));

for sr_i = 1:length(Q)
    for tar_i = 1:length(Q)
        if sr_i ~= tar_i
            [actual_dist, id_dist] = predict_with_L_R(mean_Q{sr_i}, mean_Q{tar_i});
            actual_dists_mat(sr_i, tar_i) = actual_dist;
            id_dists_mat(sr_i, tar_i) = id_dist;
        end
    end
end

for i = 1:1000
    % Shuffle right Q matrix
    mean_s_Q = mean_Q;
    for s_i = 1:length(Q)
        shuffle_indices{s_i} = randperm(size(Q{s_i}.right{1}.data, 1));
        mean_s_Q{s_i}.right = mean_Q{s_i}.right(shuffle_indices{s_i}, :);
    end

    for sr_i = 1:length(Q)
        for tar_i = 1:length(Q)
            if sr_i ~= tar_i
                [sf_dist] = predict_with_L_R(mean_s_Q{sr_i}, mean_Q{tar_i});
                sf_dists_mat{sr_i, tar_i}  = [sf_dists_mat{sr_i, tar_i}, sf_dist];

                if actual_dists_mat(sr_i, tar_i) < sf_dist
                    actual_sf_mat(sr_i, tar_i) = actual_sf_mat(sr_i, tar_i) + 1;
                end
                if id_dists_mat(sr_i, tar_i) < sf_dist
                    id_sf_mat(sr_i, tar_i) = id_sf_mat(sr_i, tar_i) + 1;
                end
            end
        end
    end
end
