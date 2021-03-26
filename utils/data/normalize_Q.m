function [Q_norm] = normalize_Q(normalization, Q)
    % Using z-score and normalization methods to decorrelate the absolute firing rate with the later PCA laten variables.
    if strcmp(normalization, 'ind_Z')
        Q_norm = structfun(@(x) zscore(x, 0, 2), Q, 'UniformOutput', false);
    elseif strcmp(normalization, 'ind_l2')        
        Q_norm = structfun(@row_wise_norm, Q, 'UniformOutput', false);
    elseif strcmp(normalization, 'ind_sub_mean')
        Q_norm = structfun(@(x) x - mean(x, 2), Q, 'UniformOutput', false);
    elseif strcmp(normalization, 'concat_Z')
        w_len = size(Q.left, 2);
        Q_norm_concat = zscore([Q.left, Q.right], 0, 2);
        Q_norm.left = Q_norm_concat(:, 1:w_len);
        Q_norm.right = Q_norm_concat(:, w_len+1:end);
    end
end
