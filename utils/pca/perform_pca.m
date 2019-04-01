function [proj_Input, eigvecs, pca_mean] = perform_pca(cfg_in, Input)
    % Concatenate Q matrix across left and right trials and perform PCA on it.
    % By default, using the normal version of PCA and 10 PCs.
    cfg_def.NNPCA = false;
    cfg_def.NumComponents = 10;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    pca_input = [Input.left, Input.right];
    pca_mean = mean(pca_input, 2);
    pca_input = pca_input - pca_mean;
    if cfg.NNPCA
        for z = 1:cfg.NumComponents %per PC
            % Monatrani algorithm, see (Montanari A, Richard E. Non-negative principal component analysis:
            % Message passing algorithms and sharp asymptotics. arXiv preprint arXiv:14064775. 2014.
            eigvecs(:, z) = NNPCA2014(pca_input);
            % check if there's Nan's in the eigenvectors!
            if sum(isnan(eigvecs(:, z))) > 1
                fprintf('NaNs!! breaking...\n');
                break;
            end
        % caclulate the corresponding eigenvalue
        alpha1(:, z) = eigvecs(:, z)' * (pca_input * pca_input') * eigvecs(:, z);
        % subtract the projection of the data on the 1st eigenvector from the data,
        % and reuse the "new data" for the next PC calc.
        pca_input = pca_input - eigvecs(:, z) * (eigvecs(:, z)' * pca_input);
        end
    else
        [eigvecs] = pca_egvecs(pca_input, cfg.NumComponents);
    end
    %  Project all other trials (both left and right trials) to the same dimension
    proj_Input.left = pca_project(Input.left, eigvecs);
    proj_Input.right = pca_project(Input.right, eigvecs);
end
