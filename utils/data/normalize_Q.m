function [Q_norm] = normalize_Q(normalization, Q)
    % Using z-score to decorrelate the absolute firing rate with the later PCA laten variables.
    if strcmp(normalization, 'ind_Z')
        Q_norm.left = zscore(Q.left, 0, 2);
        Q_norm.right = zscore(Q.right, 0, 2);
    elseif strcmp(normalization, 'ind_l2')
        Q_norm.left = row_wise_norm(Q.left);
        Q_norm.right = row_wise_norm(Q.right);
    elseif strcmp(normalization, 'concat_Z')
        w_len = size(Q.left, 2);
        Q_norm_concat = zscore([Q.left, Q.right], 0, 2);
        Q_norm.left = Q_norm_concat(:, 1:w_len);
        Q_norm.right = Q_norm_concat(:, w_len+1:end);
    end
end
