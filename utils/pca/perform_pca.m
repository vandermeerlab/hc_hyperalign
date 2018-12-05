function [proj_Input, eigvecs] = perform_pca(Input, NumComponents)
    if isfield(Input.left, 'tc') % True if Input is TC
        % Find eigen vectors on left and right concatenated TCs.
        pca_input = [Input.left.tc, Input.right.tc];
        [eigvecs] = pca_egvecs(pca_input, NumComponents);
        % Perform project using eigen vectors derived above
        proj_Input.left = pca_project(Input.left.tc, eigvecs);
        proj_Input.right = pca_project(Input.right.tc, eigvecs);
    else
        % Concatenate Q matrix across left and right trials and perform PCA on it.
        pca_input = [Input.left, Input.right];
        [eigvecs] = pca_egvecs(pca_input, NumComponents);
        %  project all other trials (both left and right trials) to the same dimension
        proj_Input.left = pca_project(Input.left, eigvecs);
        proj_Input.right = pca_project(Input.right, eigvecs);
    end
end
