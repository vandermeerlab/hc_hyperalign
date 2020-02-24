function [cell_coefs] = calculate_cell_coefs(data)
    for i = 1:length(data)
        cell_coefs{i} = [];
        whiten_left = data{i}.left + 0.00001 * rand(size(data{i}.left));
        whiten_right = data{i}.right + 0.00001 * rand(size(data{i}.right));
        for j = 1:size(whiten_left, 1)
            [coef] = corrcoef(whiten_left(j, :), whiten_right(j, :));
            cell_coefs{i} = [cell_coefs{i}, coef(1, 2)];
        end
    end
end
