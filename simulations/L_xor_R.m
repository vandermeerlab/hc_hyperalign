% Last 2.4 second, dt = 50ms
w_len = 48;
% Make two Qs - first: source, second: target
for q_i = 1:2
    % Number of neurons
    n_units = randi([40, 160]);
    Q{q_i}.left = zeros(n_units, w_len);
    Q{q_i}.right = zeros(n_units, w_len);
    for n_i = 1:n_units
        mu = rand() * w_len;
        left_has_field = rand() < 0.5;
        if left_has_field
            Q{q_i}.left(n_i, :) = gaussian_1d(w_len, 5, mu, 5);
        else
            Q{q_i}.right(n_i, :) = gaussian_1d(w_len, 5, mu, 5);
        end
    end
end

[actual_dist, id_dist] = hyperalign_L_R(Q{1}, Q{2});
actual_sf_count = 0;
id_sf_count = 0;
sf_dists = [];

for s_i = 1:1000
    s_Q = Q;
    % Shuffle source Q right matrix
    shuffle_indices = randperm(size(Q{1}.right, 1));
    s_Q{1}.right = Q{1}.right(shuffle_indices, :);

    [sf_dist] = hyperalign_L_R(s_Q{1}, Q{2});
    sf_dists = [sf_dists, sf_dist];

    if actual_dist < sf_dist
        actual_sf_count = actual_sf_count + 1;
    end
    if id_dist < sf_dist
        id_sf_count = id_sf_count + 1;
    end
end
