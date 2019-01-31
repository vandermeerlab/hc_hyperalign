function [proj_Input, eigvecs] = perform_pca(Input, NumComponents)
    % Concatenate Q matrix across left and right trials and perform PCA on it.
    pca_input = [Input.left, Input.right];
    [eigvecs] = pca_egvecs(pca_input, NumComponents);
    %  project all other trials (both left and right trials) to the same dimension
    proj_Input.left = pca_project(Input.left, eigvecs);
    proj_Input.right = pca_project(Input.right, eigvecs);
end
