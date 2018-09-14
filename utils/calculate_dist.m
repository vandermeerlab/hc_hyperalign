function [dist] = calculate_dist(X, Y)
% Calculate Euclidean distance for a pair of observations,
% one distance per timepoint and sum all of them
    dist = 0;
    for i_t = 1:size(X, 2)
        dist_per_t = sum((X(:, i_t) - Y(:, i_t)) .^ 2);
        dist = dist + dist_per_t;
    end
end

