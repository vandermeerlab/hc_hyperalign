function [Q] = L_xor_R(cfg_in)
    % Last 2.4 second, dt = 50ms, or last 41 bins (after all choice points) for TC
    cfg_def.w_len = 48;
    % Number of neurons
    cfg_def.n_units = 30;
    % Number of iterations
    cfg_def.n_iters = 100;

    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    for d_i = 1:cfg.n_iters
        for q_i = 1:19
            if length(cfg.n_units) == 1
                n_units = cfg.n_units;
            else
                n_units = cfg.n_units(q_i);
            end
            Q{d_i}{q_i}.left = zeros(n_units, cfg.w_len);
            Q{d_i}{q_i}.right = zeros(n_units, cfg.w_len);
            for n_i = 1:n_units
                mu = rand() * cfg.w_len;
                peak = rand() * 10 + 10;
                sig = rand() * 5 + 2;
                left_has_field = rand() < 0.5;
                if left_has_field
                    Q{d_i}{q_i}.left(n_i, :) = gaussian_1d(cfg.w_len, peak, mu, sig);
                else
                    Q{d_i}{q_i}.right(n_i, :) = gaussian_1d(cfg.w_len, peak, mu, sig);
                end
            end
        end
    end
end
