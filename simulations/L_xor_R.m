function [Q] = L_xor_R(cfg_in)
    % Last 2.4 second, dt = 50ms, or last 41 bins (after all choice points) for TC
    cfg_def.w_len = 48;
    % Number of neurons
    cfg_def.n_units = randi([60, 120]);

    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    rng(mean('hyperalignment'));
    % Make two Qs - first: source, second: target
    for q_i = 1:19
        Q{q_i}.left = zeros(cfg.n_units, cfg.w_len);
        Q{q_i}.right = zeros(cfg.n_units, cfg.w_len);
        for n_i = 1:cfg.n_units
            mu = rand() * cfg.w_len;
            peak = rand() * 0.5 + 0.5;
            sig = rand() * 5 + 2;
            left_has_field = rand() < 0.5;
            if left_has_field
                Q{q_i}.left(n_i, :) = gaussian_1d(cfg.w_len, peak, mu, sig);
            else
                Q{q_i}.right(n_i, :) = gaussian_1d(cfg.w_len, peak, mu, sig);
            end
        end
    end
end
