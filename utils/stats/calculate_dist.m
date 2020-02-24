function [dist] = calculate_dist(dim, X, Y)
% Calculate Euclidean distance for a pair of observations,
% one distance per timepoint and sum all of them
    w_len = size(X, 2);
    if strcmp(dim, 'all')
        dist = 0;
    elseif dim == 1
        dist = zeros(1, w_len);
    end
    for i_t = 1:size(X, 2)
        dist_per_t = sum((X(:, i_t) - Y(:, i_t)) .^ 2);
        if strcmp(dim, 'all')
            dist = dist + dist_per_t;
        elseif dim == 1
            dist(1, i_t) = dist_per_t;
        end
    end
end

