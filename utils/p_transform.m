function Z = p_transform(transform,Y)
    % Apply procrustes transformation that obtained from using procrustes function
    Z = [transform.b * Y' * transform.T + transform.c]';
end
