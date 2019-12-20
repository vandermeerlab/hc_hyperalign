function [X_norm] = row_wise_norm(X)
    % Using matlab built-in 2-norm to do row-wise normalization on matrix input. 
    for r_i = 1:size(X, 1)
        row_norm = norm(X(r_i, :));
        if row_norm ~= 0
            X_norm(r_i, :) = X(r_i, :) / row_norm;
        else
            X_norm(r_i, :) = zeros(size(X(r_i, :)));
        end
    end
end