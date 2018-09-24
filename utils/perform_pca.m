function [proj_Input] = perform_pca(Input, NumComponents)
    if strcmp(class(Input.left), 'double') % True if Input is TC
        % Find eigen vectors on left and right concatenated TCs.
        pca_input = [Input.left, Input.right];
        [eigvecs] = pca_egvecs(pca_input, NumComponents);
        % Perform project using eigen vectors derived above
        proj_Input.left = pca_project(Input.left, eigvecs);
        proj_Input.right = pca_project(Input.right, eigvecs);
    else
        % Concatenate Q matrix across all trials and perform PCA on it.
        pca_input = [];
        % Do the left trials first.
        for i = 1:length(Input.left)
            pca_input = [pca_input Input.left{i}.data];
        end

        % Do the right trials.
        for i = 1:length(Input.right)
            pca_input = [pca_input Input.right{i}.data];
        end

        [eigvecs] = pca_egvecs(pca_input, NumComponents);

        %  project all other trials (both left and right trials) to the same dimension
        for i = 1:length(Input.left)
            input_matrix = Input.left{i}.data;
            proj_Input.left{i} = pca_project(input_matrix, eigvecs);
        end
        for i = 1:length(Input.right)
            input_matrix = Input.right{i}.data;
            proj_Input.right{i} = pca_project(input_matrix, eigvecs);
        end
    end
end
