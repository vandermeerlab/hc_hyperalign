function [dist] = predict_late_from_early(cfg_in, source, target)
    % most of this code is adapted from predict_without_neuron.m
    % (many pieces of which are copied from predict_with_L_R.m)

    % Source and target both have .early and .late attributes, which are
    % all num_neurons x num_bins matrices
     
    % do some config file stuff
    cfg_def.dist_dim = 'all';
    cfg_def.NumComponents = 10;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def, cfg_in, mfun);
    
    % Project [L, R] to PCA space for all sources
%     for p_i = 1:length(Q)
%         [proj_Q{p_i}, eigvecs{p_i}, pca_mean{p_i}] = perform_pca(Q{p_i}, cfg.NumComponents);
%     end

    % TODO find a better work-around
    source.left = source.early; source.right = source.late;
    target.left = target.early; target.right = target.late;

%     QUESTION: are you sure it's ok to project only two sessions into PCA space?
    [proj_source, eigvecs_source, pca_mean_source] = perform_pca(source, cfg.NumComponents);
    [proj_target, eigvecs_target, pca_mean_target] = perform_pca(target, cfg.NumComponents);
    
    % TODO find a better work-around here as well
    % proj_source.left = proj_source.early; proj_source.right = proj_source.late;
    % proj_target.left = proj_target.early; proj_target.right = proj_target.late;
    
    % Perform hyperalignment on the PCA of the source-target pair
    hyper_input = {proj_source, proj_target};
    
    [aligned_early, aligned_late, transforms] = get_aligned_left_right(hyper_input);

    aligned_early_sr = aligned_early{1};
    aligned_late_sr = aligned_late{1};
    aligned_early_tar = aligned_early{2};
    transforms_tar = transforms{2};

    % Estimate M from L to R using source session.
    [~, ~, M] = procrustes(aligned_late_sr', aligned_early_sr', 'scaling', false);

    % Apply M to L of target session to predict.
    predicted_aligned = p_transform(M, aligned_early_tar);

    % Project back to PCA space
    project_back_pca = inv_p_transform(transforms_tar, [aligned_early_tar, predicted_aligned]);
    %project_back_pca_id = inv_p_transform(transforms_tar, [aligned_left_tar, id_predicted_aligned]);

    % Project back to Q space.
    project_back_Q = eigvecs_target * project_back_pca + pca_mean_target;
    w_len = size(aligned_early_sr, 2);
    p_target = project_back_Q(:, w_len+1:end);
    ground_truth = target.late;

    % Compare prediction using M with ground truth
    dist = calculate_dist(cfg.dist_dim, p_target, ground_truth);
