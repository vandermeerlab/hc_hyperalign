function [proj_Input, eigvecs, pca_mean] = perform_pca(Input, NumComponents)
    w_len = size(Input.left, 2);
    % Concatenate Q matrix across left and right trials and perform PCA on it.
    pca_input = [Input.left, Input.right];
    pca_mean = mean(pca_input, 2);
    pca_input_centered = pca_input - pca_mean;
    [eigvecs] = pca_egvecs(pca_input_centered, NumComponents);
    %  project all other trials (both left and right trials) to the same dimension
    pca_projected = pca_project(pca_input_centered, eigvecs);
    proj_Input.left = pca_projected(:, 1:w_len);
    proj_Input.right = pca_projected(:, w_len+1:end);
end
