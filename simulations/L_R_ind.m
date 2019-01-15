% Last 2.4 second, dt = 50ms
w_len = 48;
% Make two Qs - first: source, second: target
for q_i = 1:19
    % Number of neurons
    n_units = randi([40, 160]);
    Q{q_i}.left = zeros(n_units, w_len);
    Q{q_i}.right = zeros(n_units, w_len);
    p_has_field = 0.5;
    for n_i = 1:n_units
        mu = rand() * w_len;
        if rand() < p_has_field
%             left_mu = rand() * w_len;
            Q{q_i}.left(n_i, :) = gaussian_1d(w_len, 5, mu, 5);
        end
        if rand() < p_has_field
%             right_mu = rand() * w_len;
            Q{q_i}.right(n_i, :) = gaussian_1d(w_len, 5, mu, 5);
        end
    end
end

actual_dists_mat  = zeros(length(Q));
id_dists_mat  = zeros(length(Q));
sf_dists_mat  = cell(length(Q));
actual_sf_mat = zeros(length(Q));
id_sf_mat = zeros(length(Q));

for sr_i = 1:length(Q)
    for tar_i = 1:length(Q)
        if sr_i ~= tar_i
            [actual_dist, id_dist] = predict_Q_with_L_R(Q{sr_i}, Q{tar_i});
            actual_dists_mat(sr_i, tar_i) = actual_dist;
            id_dists_mat(sr_i, tar_i) = id_dist;
        end
    end
end

for shuffle_i = 1:1000
    % Shuffle right Q matrix
    s_Q = Q;
    for s_i = 1:length(Q)
        shuffle_indices{s_i} = randperm(size(Q{s_i}.right, 1));
        s_Q{s_i}.right = Q{s_i}.right(shuffle_indices{s_i}, :);
    end

    for sr_i = 1:length(Q)
        for tar_i = 1:length(Q)
            if sr_i ~= tar_i
                [sf_dist] = predict_Q_with_L_R(s_Q{sr_i}, Q{tar_i});
                sf_dists_mat{sr_i, tar_i}  = [sf_dists_mat{sr_i, tar_i}, sf_dist];

                if actual_dists_mat(sr_i, tar_i) < sf_dist
                    actual_sf_mat(sr_i, tar_i) = actual_sf_mat(sr_i, tar_i) + 1;
                end
                if id_dists_mat(sr_i, tar_i) < sf_dist
                    id_sf_mat(sr_i, tar_i) = id_sf_mat(sr_i, tar_i) + 1;
                end
            end
        end
    end
end

