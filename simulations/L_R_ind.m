%% Prepare input
% Last 2.4 second, dt = 50ms
w_len = 48;
% Or last 41 bins (after all choice points) for TC
% w_len = 41;
rng(mean('hyperalignment'));
% Make two Qs - first: source, second: target
for q_i = 1:19
    % Number of neurons
    n_units = randi([60, 120]);
    Q{q_i}.left = zeros(n_units, w_len);
    Q{q_i}.right = zeros(n_units, w_len);
    p_has_field = 0.5;
    for n_i = 1:n_units
        % mu = rand() * w_len;
        % peak = rand() * 0.5 + 0.5;
        % sig = rand() * 5 + 2;
        if rand() < p_has_field
            left_mu = rand() * w_len;
            left_peak = rand() * 0.5 + 0.5;
            left_sig = rand() * 5 + 2;
            Q{q_i}.left(n_i, :) = gaussian_1d(w_len, left_peak, left_mu, left_sig);
        end
        if rand() < p_has_field
            right_mu = rand() * w_len;
            right_peak = rand() * 0.5 + 0.5;
            right_sig = rand() * 5 + 2;
            Q{q_i}.right(n_i, :) = gaussian_1d(w_len, right_peak, right_mu, right_sig);
        end
    end
    % Different normalization.
    % Ind. normalization
    Q_norm_ind{q_i} = normalize_Q('ind', Q{q_i});
    % Concat. normalization
    Q_norm_concat{q_i} = normalize_Q('concat', Q{q_i});
    % Subtract the means
    Q_norm_sub{q_i} = normalize_Q('sub_mean', Q{q_i});
end
