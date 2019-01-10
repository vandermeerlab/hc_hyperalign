% Last 2.4 second, dt = 50ms
w_len = 48;
% Make two Qs - first: source, second: target
for i = 1:2
    % Number of neurons
    n_units = randi([40, 160]);
    Q{i}.left = zeros(n_units, w_len);
    Q{i}.right = zeros(n_units, w_len);
    for j = 1:n_units
        mu = rand() * w_len;
        left_has_field = rand() < 0.5;
        if left_has_field
            Q{i}.left(j, :) = gaussian_1d(w_len, 5, mu, 5);
        else
            Q{i}.right(j, :) = gaussian_1d(w_len, 5, mu, 5);
        end
    end
end