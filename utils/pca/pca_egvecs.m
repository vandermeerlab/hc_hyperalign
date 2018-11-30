function [Egvecs] = pca_egvecs(InputMatrix, NumComponents)

    % InputMatrix is a matrix by N(neurons) by T(time)
    % output is the Eigen Vectors N neurons and NumComponents
    
    [U, S, V] = svd(InputMatrix);
    [Egvecs] = U(:, 1:NumComponents);

end
