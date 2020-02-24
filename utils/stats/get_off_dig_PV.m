function [off_diag_coefs] = get_off_dig_PV(coefs)
    % Get off-diagonal elements from a PV coefficients matrix.
    w_len = size(coefs{1}, 2);
    off_diag_coefs = zeros(w_len/2, length(coefs));
    for c_i = 1:length(coefs)
        off_diag_coefs(:, c_i) = diag(coefs{c_i}(1:w_len/2, (w_len/2+1):end));
    end
end
