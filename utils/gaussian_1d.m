function f = gaussian_1d(N, a, mu, sig)
    % function f = gaussian_1d(N, mu, sig)
    %
    % Create a gaussian 1d function with amplitude and without normalizing.
    %
    % INPUTS
    % N: Length of time window
    % a: Amplitude
    % mu: Mean
    % sig (sigma): Variance
    % f = exp(-x.^2/(2*sig^2)-y.^2/(2*sig^2));
    x = 1:N;
    f = a * 1/(sig * sqrt(2*pi)) * exp(-((x - mu).^2) / (2 * sig^2));
end
