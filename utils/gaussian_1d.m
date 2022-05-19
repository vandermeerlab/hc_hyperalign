function f = gaussian_1d(T, a, mu, sig)
    % function f = gaussian_1d(T, mu, sig)
    %
    % Create a gaussian 1d function with amplitude and without normalizing.
    %
    % INPUTS
    % T: Length of time window
    % a: Amplitude
    % mu: Mean
    % sig (sigma): Variance
    % f = exp(-x.^2/(2*sig^2)-y.^2/(2*sig^2));
    x = 1:T;
    % Keep 1/(sig * sqrt(2*pi)) (normalization factor) out since we will
    % z-score later and make amplitude as height of the peak.
    f = a * exp(-((x - mu).^2) / (2 * sig^2));
    f = f / sum(f);
end
