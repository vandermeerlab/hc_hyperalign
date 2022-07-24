function [actual_dist, p_target] = predict_with_template_align(template, V, eigvec, pca_mean, ground_truth)

% Align the withheld subject to template
hyper_input_val = {template, V};
[aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input_val);
aligned_left_template = aligned_left{1};
aligned_right_template = aligned_right{1};
aligned_left_val = aligned_left{2};
transforms_val = transforms{2};

% Estimate M from L to R using the template.
[~, ~, M] = procrustes(aligned_right_template', aligned_left_template', 'scaling', false);
% Apply M to L of the validate session V.
predicted_aligned = p_transform(M, aligned_left_val);

% Project back to PCA space
project_back_pca = inv_p_transform(transforms_val, [aligned_left_val, predicted_aligned]);

% Project back to DATA space.
project_back_data = eigvec * project_back_pca + pca_mean;

w_len = size(template.left, 2);
p_target = project_back_data(:, w_len+1:end);

cfg.dist_dim = 'all';
actual_dist = calculate_dist(cfg.dist_dim, p_target, ground_truth);

end