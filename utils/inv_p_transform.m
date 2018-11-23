function Y = inv_p_transform(transform, Z)
    % Inverse procrustes transformation
    Y = [inv(transform.b) * (Z' - transform.c) * inv(transform.T)]';
end
