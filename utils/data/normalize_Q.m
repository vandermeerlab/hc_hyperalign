function [Q_norm] = normalize_Q(normalization, Q)
    % Using z-score to decorrelate the absolute firing rate with the later PCA laten variables.
    if strcmp(normalization, 'ind')
        % Q_norm.left = zscore(Q.left, 0, 2);
        % Q_norm.right = zscore(Q.right, 0, 2);
        Q_norm.left = Q.left - mean(Q.left, 2);
        Q_norm.right = Q.right - mean(Q.right, 2);
    elseif strcmp(normalization, 'concat')
        w_len = size(Q.left, 2);
        % Q_norm_concat = zscore([Q.left, Q.right], 0, 2);
        % Q_norm.left = Q_norm_concat(:, 1:w_len);
        % Q_norm.right = Q_norm_concat(:, w_len+1:end);
        Q_norm.left = Q.left - mean([Q.left, Q.right], 2);
        Q_norm.right = Q.right - mean([Q.left, Q.right], 2);
    end
end
