function [actual_dists_mat, id_dists_mat] = predict_with_L_R_pca(cfg_in, Q)
    % Perform PCA, and obtain procrustes transformation in PCA space
    % and predict target (trajectory of Q matrix).
    % The way that this function obtains procrustes is concatenating left(L) and right(R) into [L, R].
    % If shuffled is specified, source session would be identity shuffled.
    cfg_def.shuffled = 0;
    cfg_def.NumComponents = 10;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    % Project [L, R] to PCA space.
    for p_i = 1:length(Q)
        [proj_Q{p_i}, eigvecs{p_i}, pca_mean{p_i}] = perform_pca(Q{p_i}, cfg.NumComponents);
    end

    if cfg.shuffled
        % Shuffle right Q matrix
        s_Q = Q;
        for s_i = 1:length(Q)
            shuffle_indices = randperm(size(Q{s_i}.right, 1));
            s_Q{s_i}.right = Q{s_i}.right(shuffle_indices, :);
            [s_proj_Q{s_i}] = perform_pca(s_Q{s_i}, cfg.NumComponents);
        end
    end

    actual_dists_mat  = zeros(length(Q));
    id_dists_mat  = zeros(length(Q));
    for sr_i = 1:length(Q)
        for tar_i = 1:length(Q)
            if sr_i ~= tar_i
                if cfg.shuffled
                    left_sr = s_proj_Q{sr_i}.left;
                    right_sr = s_proj_Q{sr_i}.right;
                    left_tar = proj_Q{tar_i}.left;
                    right_tar = proj_Q{tar_i}.right;
                else
                    left_sr = proj_Q{sr_i}.left;
                    right_sr = proj_Q{sr_i}.right;
                    left_tar = proj_Q{tar_i}.left;
                    right_tar = proj_Q{tar_i}.right;
                end
                % Estimate M from L to R using source session.
                [~, ~, M] = procrustes(right_sr', left_sr', 'scaling', false);
                % Apply M to L of target session to predict.
                predicted_pca = p_transform(M, left_tar);
                % Estimate using L (identity mapping).
                id_predicted_aligned = left_tar;

                % Project back to Q space.
                project_back_Q_right = eigvecs{tar_i} * predicted_pca + pca_mean{tar_i};
                project_back_Q_id_right = eigvecs{tar_i} * id_predicted_aligned + pca_mean{tar_i};
                p_target = project_back_Q_right;
                id_p_target = project_back_Q_id_right;
                ground_truth = Q{tar_i}.right;

                % Compare prediction using M with ground truth
                actual_dist = calculate_dist(p_target, ground_truth);
                id_dist = calculate_dist(id_p_target, ground_truth);
                actual_dists_mat(sr_i, tar_i) = actual_dist;
                id_dists_mat(sr_i, tar_i) = id_dist;
            end
        end
    end
end
