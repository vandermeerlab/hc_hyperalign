function [coefs] = calculate_PV_coefs(data)
    % Calculate PV coefficients for each session in data.
    data = cellfun(@(x) [x.left, x.right], data, 'UniformOutput', false);
    coefs = cell(1, length(data));
    w_len = size(data{1}, 2);
    for i = 1:length(data)
        w_coefs = zeros(w_len, w_len);
        for j = 1:w_len
            for k = 1:w_len
                [coef] = corrcoef(data{i}(:, j), data{i}(:, k));
                w_coefs(j, k) = coef(1, 2);
            end
        end
        coefs{i} = w_coefs;
    end
end
