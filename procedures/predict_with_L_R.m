function [actual_dists_mat, id_dists_mat, predicted_Q_mat] = predict_with_L_R(cfg_in, Q)
    % Perform PCA, hyperalignment (with either two or all sessions)
    % and predict target (either trajectory in common space, PCA space or Q matrix).
    % The way that this function performs hyperalignment is concatenating left(L) and right(R) into [L, R].
    cfg_def.NumComponents = 10;
    cfg_def.hyperalign_all = false;
    % Could be 'common', 'pca', or 'Q'.
    cfg_def.predict_target = 'Q';
    % If shuffled is specified, source session would be identity shuffled.
    cfg_def.shuffled = 0;
    % Using z-score to decorrelate the absolute firing rate with the later PCA laten variables if not none.
    cfg_def.normalization = 'none';
    % Use 'all' to calculate a squared error (scalar) between predicted and actual.
    % Use 1 to sum across PCs (or units) and obtain a vector of squared errors.
    cfg_def.dist_dim = 'all';
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    % Project [L, R] to PCA space.
    for p_i = 1:length(Q)
        if strcmp(cfg.normalization, 'none')
            pca_input = Q{p_i};
        else
            Q_norm{p_i} = normalize_Q(cfg.normalization, Q{p_i});
            pca_input = Q_norm{p_i};
        end
        [proj_Q{p_i}, eigvecs{p_i}, pca_mean{p_i}] = perform_pca(pca_input, cfg.NumComponents);
    end

    if cfg.shuffled
        % Shuffle right Q matrix
        s_Q = Q;
        for s_i = 1:length(Q)
            shuffle_indices = randperm(size(Q{s_i}.right, 1));
            s_Q{s_i}.right = Q{s_i}.right(shuffle_indices, :);

            if strcmp(cfg.normalization, 'none')
                s_pca_input = s_Q{s_i};
            else
                s_Q_norm = normalize_Q(cfg.normalization, s_Q{s_i});
                s_pca_input = s_Q_norm;
            end
            [s_proj_Q{s_i}] = perform_pca(s_pca_input, cfg.NumComponents);
        end
    end

    actual_dists_mat  = cell(length(Q));
    id_dists_mat  = cell(length(Q));
    predicted_Q_mat = cell(length(Q));
    for sr_i = 1:length(Q)
        if cfg.hyperalign_all
            % Hyperalign using all sessions then source will be chosen to predict target.
            % Perform hyperalignment on concatenated [L, R] in PCA.
            hyper_input = proj_Q;
            if cfg.shuffled
                hyper_input{sr_i} = s_proj_Q{sr_i};
            end
            [aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);
        end
        for tar_i = 1:length(Q)
            if sr_i ~= tar_i
                if cfg.hyperalign_all
                    aligned_left_sr = aligned_left{sr_i};
                    aligned_right_sr = aligned_right{sr_i};
                    aligned_left_tar = aligned_left{tar_i};
                    aligned_right_tar = aligned_right{tar_i};
                    transforms_tar = transforms{tar_i};
                else
                    % Perform hyperalignment on concatenated [L, R] in PCA for every source-target pair.
                    if cfg.shuffled
                        hyper_input = {s_proj_Q{sr_i}, proj_Q{tar_i}};
                    else
                        hyper_input = {proj_Q{sr_i}, proj_Q{tar_i}};
                    end
                    [aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);
                    aligned_left_sr = aligned_left{1};
                    aligned_right_sr = aligned_right{1};
                    aligned_left_tar = aligned_left{2};
                    aligned_right_tar = aligned_right{2};
                    transforms_tar = transforms{2};
                end
                % Estimate M from L to R using source session.
                [~, ~, M] = procrustes(aligned_right_sr', aligned_left_sr', 'scaling', false);
                % Apply M to L of target session to predict.
                predicted_aligned = p_transform(M, aligned_left_tar);
                % Estimate using L (identity mapping).
                id_predicted_aligned = aligned_left_tar;
                % Project back to PCA space
                project_back_pca = inv_p_transform(transforms_tar, [aligned_left_tar, predicted_aligned]);
                project_back_pca_id = inv_p_transform(transforms_tar, [aligned_left_tar, id_predicted_aligned]);
                % Project back to Q space.
                project_back_Q = eigvecs{tar_i} * project_back_pca + pca_mean{tar_i};
                project_back_Q_id = eigvecs{tar_i} * project_back_pca_id + pca_mean{tar_i};

                w_len = size(aligned_left_sr, 2);
                if strcmp(cfg.predict_target, 'common')
                    p_target = predicted_aligned;
                    id_p_target = id_predicted_aligned;
                    ground_truth = aligned_right_tar;
                elseif strcmp(cfg.predict_target, 'pca')
                    p_target = project_back_pca(:, w_len+1:end);
                    id_p_target = project_back_pca_id(:, w_len+1:end);
                    ground_truth = proj_Q{tar_i}.right;
                elseif strcmp(cfg.predict_target, 'Q')
                    p_target = project_back_Q(:, w_len+1:end);
                    id_p_target = project_back_Q_id(:, w_len+1:end);
                    if strcmp(cfg.normalization, 'none')
                        ground_truth = Q{tar_i}.right;
                    else
                        ground_truth = Q_norm{tar_i}.right;
                    end
                end
                % Compare prediction using M with ground truth
                actual_dist = calculate_dist(cfg.dist_dim, p_target, ground_truth);
                id_dist = calculate_dist(cfg.dist_dim, id_p_target, ground_truth);
                actual_dists_mat{sr_i, tar_i} = actual_dist;
                id_dists_mat{sr_i, tar_i} = id_dist;
                predicted_Q_mat{sr_i, tar_i} = project_back_Q;
            else
                actual_dists_mat{sr_i, tar_i} = NaN;
                id_dists_mat{sr_i, tar_i} = NaN;
                predicted_Q_mat{sr_i, tar_i} = NaN;
            end
        end
    end
    if strcmp(cfg.dist_dim, 'all')
        actual_dists_mat  = cell2mat(actual_dists_mat);
        id_dists_mat  = cell2mat(id_dists_mat);
    end
end
