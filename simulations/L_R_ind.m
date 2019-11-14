function [Q] = L_R_ind(cfg_in)
    % Last 2.4 second, dt = 50ms, or last 41 bins (after all choice points) for TC
    cfg_def.w_len = 48;
    % 1st: mu (location), 2nd: peak (amplitude), 3rd: sigma (width).
    % 1 means the same in L and R. 0 means random. Default is all three params are the same.
    cfg_def.same_params = [0, 0, 0];
    cfg_def.p_has_field = 0.5;
    % Number of neurons
    cfg_def.n_units = randi([60, 120]);

    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    rng(mean('hyperalignment'));
    for d_i = 1:19
        for q_i = 1:19
            % Number of neurons
            Q{d_i}{q_i}.left = zeros(cfg.n_units, cfg.w_len);
            Q{d_i}{q_i}.right = zeros(cfg.n_units, cfg.w_len);
            for n_i = 1:cfg.n_units
                mu = rand() * cfg.w_len;
                peak = rand() * 0.5 + 0.5;
                sig = rand() * 5 + 2;
                if rand() < cfg.p_has_field
                    Q{d_i}{q_i}.left(n_i, :) = gaussian_1d(cfg.w_len, peak, mu, sig);
                end
                if rand() < cfg.p_has_field
                    if cfg.same_params(1)
                        right_mu = mu;
                    else
                        right_mu = rand() * cfg.w_len;
                    end
                    if cfg.same_params(2)
                        right_peak = peak;
                    else
                        right_peak = rand() * 0.5 + 0.5;
                    end
                    if cfg.same_params(3)
                        right_sig = sig;
                    else
                        right_sig = rand() * 5 + 2;
                    end
                    Q{d_i}{q_i}.right(n_i, :) = gaussian_1d(cfg.w_len, right_peak, right_mu, right_sig);
                end
            end
        end
    end
end
