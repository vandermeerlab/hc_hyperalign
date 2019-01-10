function [actual_dist, id_dist] = hyperalign_L_R(sr_Q, tar_Q)
    % Project [L, R] to PCA space.
    NumComponents = 10;
    [sr_proj_Q, sr_eigvecs] = perform_pca(sr_Q, NumComponents);
    [tar_proj_Q, tar_eigvecs] = perform_pca(tar_Q, NumComponents);
    % Perform hyperalignment on concatenated [L, R] in PCA.
    hyper_input = {sr_proj_Q, tar_proj_Q};
    [aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);
    % Estimate M from L to R using source session.
    [~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}');
    % Apply M to L of target session to predict.
    predicted = p_transform(M, aligned_left{2});
    % Estimate using L (identity mapping).
    id_predicted = aligned_left{2};
    % Project back to PCA space
    padding = zeros(size(aligned_left{1}));
    project_back_pca = inv_p_transform(transforms{2}, [padding, predicted]);
    project_back_pca_id = inv_p_transform(transforms{2}, [padding, id_predicted]);
    % Project back to Q space.
    w_len = size(sr_Q.left, 2);
    project_back_Q_right = tar_eigvecs * project_back_pca(:, w_len+1:end);
    project_back_Q_id_right = tar_eigvecs * project_back_pca_id(:, w_len+1:end);
    % Compare prediction using M with ground truth
    ground_truth_Q = tar_Q.right;
    actual_dist = calculate_dist(project_back_Q_right, ground_truth_Q);
    id_dist = calculate_dist(project_back_Q_id_right, ground_truth_Q);
end
