function [left, right] = get_mixture_cell(p_xor, p_same_mu)
    w_len = 48;
    left = zeros(1, w_len);
    right = zeros(1, w_len);

    mu = rand() * w_len;
    peak = rand() * 0.5 + 0.5;
    sig = rand() * 5 + 2;

    p_mixture = rand();
    if p_mixture < p_xor
        % L_xor_R
        left_has_field = rand() < 0.5;
        if left_has_field
            left = gaussian_1d(w_len, peak, mu, sig);
        else
            right = gaussian_1d(w_len, peak, mu, sig);
        end
    elseif p_mixture < (p_xor + p_same_mu)
        % L_R_ind_same_mu
        p_has_field = 0.5;
        if rand() < p_has_field
            left = gaussian_1d(w_len, rand() * 0.5 + 0.5, mu, rand() * 5 + 2);
        end
        if rand() < p_has_field
            right = gaussian_1d(w_len, rand() * 0.5 + 0.5, mu, rand() * 5 + 2);
        end
    else
        % L_R_ind
        p_has_field = 0.5;
        if rand() < p_has_field
            left = gaussian_1d(w_len, rand() * 0.5 + 0.5, rand() * w_len, rand() * 5 + 2);
        end
        if rand() < p_has_field
            right = gaussian_1d(w_len, rand() * 0.5 + 0.5, rand() * w_len, rand() * 5 + 2);
        end
    end
end
