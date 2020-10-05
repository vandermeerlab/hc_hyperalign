function [dist] = predict_with_L_R_functional(cfg_in, Q, source, target)
    % many pieces of this code are copied from predict_with_L_R.m

    % "source" and "target" are indices into Q, which currently has 19 different sessions.
     
    % do some config file stuff
    cfg_def.dist_dim = 'all';
    cfg_def.NumComponents = 10;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def, cfg_in, mfun);
    
    % Project [L, R] to PCA space for all sources
    for p_i = 1:length(Q)
        [proj_Q{p_i}, eigvecs{p_i}, pca_mean{p_i}] = perform_pca(Q{p_i}, cfg.NumComponents);
    end

    % Perform hyperalignment on the PCA of the source-target pair
    hyper_input = {proj_Q{source}, proj_Q{target}};

    [aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);

    aligned_left_sr = aligned_left{1};
    aligned_right_sr = aligned_right{1};
    aligned_left_tar = aligned_left{2};
    transforms_tar = transforms{2};

    % Estimate M from L to R using source session.
    [~, ~, M] = procrustes(aligned_right_sr', aligned_left_sr', 'scaling', false);

    % Apply M to L of target session to predict.
    predicted_aligned = p_transform(M, aligned_left_tar);

    % Project back to PCA space
    project_back_pca = inv_p_transform(transforms_tar, [aligned_left_tar, predicted_aligned]);
    %project_back_pca_id = inv_p_transform(transforms_tar, [aligned_left_tar, id_predicted_aligned]);

    % Project back to Q space.
    project_back_Q = eigvecs{target} * project_back_pca + pca_mean{target};
    w_len = size(aligned_left_sr, 2);
    p_target = project_back_Q(:, w_len+1:end);
    ground_truth = Q{target}.right;

    % Compare prediction using M with ground truth
    dist = calculate_dist(cfg.dist_dim, p_target, ground_truth);
