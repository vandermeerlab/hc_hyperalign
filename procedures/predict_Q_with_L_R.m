function [actual_dists_mat, id_dists_mat] = predict_with_L_R(cfg_in, Q)
    % Perform PCA, hyperalignment (with either two or all sessions) and predict target Q matrices.
    cfg_def.hyperalign_all = false;
    cfg_def.predict_Q = true;
    cfg_def.NumComponents = 10;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    % Project [L, R] to PCA space.
    for p_i = 1:length(Q)
        [proj_Q{p_i}, eigvecs{p_i}] = perform_pca(Q{p_i}, cfg.NumComponents);
    end

    actual_dists_mat  = zeros(length(Q));
    id_dists_mat  = zeros(length(Q));
    if cfg.hyperalign_all
        % Hyperalign using all sessions then source will be chosen to predict target.
        % Perform hyperalignment on concatenated [L, R] in PCA.
        hyper_input = proj_Q;
        [aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);
    end
    for sr_i = 1:length(Q)
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
                    hyper_input = {proj_Q{sr_i}, proj_Q{tar_i}};
                    [aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);
                    aligned_left_sr = aligned_left{1};
                    aligned_right_sr = aligned_right{1};
                    aligned_left_tar = aligned_left{2};
                    aligned_right_tar = aligned_right{2};
                    transforms_tar = transforms{2};
                end
                % Estimate M from L to R using source session.
                [~, ~, M] = procrustes(aligned_right_sr', aligned_left_sr');
                % Apply M to L of target session to predict.
                predicted_aligned = p_transform(M, aligned_left_tar);
                % Estimate using L (identity mapping).
                id_predicted_aligned = aligned_left_tar;
                if ~predict_Q
                    p_target = predicted_aligned;
                    id_p_target = id_predicted_aligned;
                    % Compare prediction using M with ground truth
                    ground_truth = aligned_right_tar;
                else
                    % Project back to PCA space
                    padding = zeros(size(aligned_left_sr));
                    project_back_pca = inv_p_transform(transforms_tar, [padding, predicted_aligned]);
                    project_back_pca_id = inv_p_transform(transforms_tar, [padding, id_predicted_aligned]);
                    % Project back to Q space.
                    w_len = size(aligned_left_sr, 2);
                    project_back_Q_right = eigvecs{tar_i} * project_back_pca(:, w_len+1:end);
                    project_back_Q_id_right = eigvecs{tar_i} * project_back_pca_id(:, w_len+1:end);
                    p_target = project_back_Q_right;
                    id_p_target = project_back_Q_id_right;
                    ground_truth = Q{tar_i}.right;
                end
                actual_dist = calculate_dist(p_target, ground_truth);
                id_dist = calculate_dist(id_p_target, ground_truth);
                actual_dists_mat(sr_i, tar_i) = actual_dist;
                id_dists_mat(sr_i, tar_i) = id_dist;
            end
        end
    end
end
