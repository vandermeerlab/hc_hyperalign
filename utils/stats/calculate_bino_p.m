function [bino_p] = calculate_bino_p(x, n, p)
    % Calculate the p-value (two-sided) given by bino(x, n, p)
    p = binocdf(x, n, p);
    if p > 0.5
        bino_p = (1 - p) * 2;
    else
        bino_p = p * 2;
    end
end
