%% Prepare input
% Last 2.4 second, dt = 50ms
w_len = 48;
% Or last 41 bins (after all choice points) for TC
% w_len = 41;
rng(mean('hyperalignment'));

for q_i = 1:19
    [w_xor, w_same_mu, w_ind] = get_rand_discrete_probs();
    % Number of neurons
    n_units = randi([60, 120]);
    Q{q_i}.left = zeros(n_units, w_len);
    Q{q_i}.right = zeros(n_units, w_len);
    for n_i = 1:n_units
        [L_xor, R_xor] = get_mixture_cell(1, 0);
        [L_same_mu, R_same_mu] = get_mixture_cell(0, 1);
        [L_ind, R_ind] = get_mixture_cell(0, 0);
        Q{q_i}.left(n_i, :) = w_xor * L_xor + w_same_mu * L_same_mu + w_ind * L_ind;
        Q{q_i}.right(n_i, :) = w_xor * R_xor + w_same_mu * R_same_mu + w_ind * R_ind;
    end
    % Different normalization.
    % Ind. normalization
    Q_norm_ind{q_i} = normalize_Q('ind', Q{q_i});
    % Concat. normalization
    Q_norm_concat{q_i} = normalize_Q('concat', Q{q_i});
    % Subtract the means
    Q_norm_sub{q_i} = normalize_Q('sub_mean', Q{q_i});
end
