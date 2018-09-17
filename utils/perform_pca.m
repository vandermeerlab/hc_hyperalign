function [proj_Q] = perform_pca(Q, NumComponents)
    % Concatenate Q matrix across all trials and perform PCA on it.
    pca_input = [];
    % Do the left trials first.
    for i = 1:length(Q.left)
        pca_input = [pca_input Q.left{i}.data];
    end

    % Do the right trials.
    for i = 1:length(Q.right)
        pca_input = [pca_input Q.right{i}.data];
    end

    [eigvecs] = pca_egvecs(pca_input, NumComponents);

    %  project all other trials (both left and right trials) to the same dimension
    for i = 1:length(Q.left)
        input_matrix = Q.left{i}.data;
        proj_Q.left{i} = pca_project(input_matrix, eigvecs);
    end
    for i = 1:length(Q.right)
        input_matrix = Q.right{i}.data;
        proj_Q.right{i} = pca_project(input_matrix, eigvecs);
    end
end
