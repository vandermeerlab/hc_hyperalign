function [X_norm, row_norms] = row_wise_norm(X)
    % Using matlab built-in 2-norm to do row-wise normalization on matrix input.
    row_norms = zeros(size(X, 1), 1);
    for r_i = 1:size(X, 1)
        row_norm = norm(X(r_i, :));
        row_norms(r_i) = row_norm;
        if row_norm ~= 0
            X_norm(r_i, :) = X(r_i, :) / row_norm;
        else
            X_norm(r_i, :) = zeros(size(X(r_i, :)));
        end
    end
end
