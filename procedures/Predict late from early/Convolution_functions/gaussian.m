% Created by Will Baxley on 9/2/2020.

% There are two parameters in params: [mean (i.e. center), standard_deviation]
function y = gaussian(params, x)
    mu = params(1);
    sd = params(2);
    y = 1/(sqrt(2*pi)*sd)*exp(-(x-mu).^2/(2*sd^2));