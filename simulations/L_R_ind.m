function [Q] = L_R_ind(cfg_in)
    % Last 2.4 second, dt = 50ms, or last 41 bins (after all choice points) for TC
    cfg_def.w_len = 48;
    cfg_def.same_mu = 0;

    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    rng(mean('hyperalignment'));
    for q_i = 1:19
        % Number of neurons
        n_units = randi([60, 120]);
        Q{q_i}.left = zeros(n_units, cfg.w_len);
        Q{q_i}.right = zeros(n_units, cfg.w_len);
        p_has_field = 0.5;
        for n_i = 1:n_units
            mu = rand() * cfg.w_len;
            if rand() < p_has_field
                if cfg.same_mu
                    left_mu = mu;
                else
                    left_mu = rand() * cfg.w_len;
                end
                left_peak = rand() * 0.5 + 0.5;
                left_sig = rand() * 5 + 2;
                Q{q_i}.left(n_i, :) = gaussian_1d(cfg.w_len, left_peak, left_mu, left_sig);
            end
            if rand() < p_has_field
                if cfg.same_mu
                    right_mu = mu;
                else
                    right_mu = rand() * cfg.w_len;
                end
                right_peak = rand() * 0.5 + 0.5;
                right_sig = rand() * 5 + 2;
                Q{q_i}.right(n_i, :) = gaussian_1d(cfg.w_len, right_peak, right_mu, right_sig);
            end
        end
    end
end
