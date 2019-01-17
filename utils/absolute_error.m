function [ae] = absolute_error(x, y)
    % Calculate Absolute Errors between two matrices
    ae = sum(abs(x(:) - y(:)));
end
