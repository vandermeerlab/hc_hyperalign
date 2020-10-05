% Created by Will Baxley on 9/2/2020.

% The distribution takes only one parameter: the alpha constant, a
function y = alpha(a, x)
    y = 0;
    if x > 0
        y = normpdf(a - (1/x)) / (x * x * normcdf(a));
    end