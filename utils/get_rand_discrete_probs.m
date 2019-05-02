function [p1, p2, p3] = get_rand_discrete_probs()
    % Get three random discrete probabilities, summing up to 1.
    rand_int = randi([0, 10]);
    p1 = rand_int / 10;
    rand_int_2 = randi([rand_int, 10]);
    p2 = rand_int_2 / 10 - p1;
    p3 = 1 - p2 - p1;
end
