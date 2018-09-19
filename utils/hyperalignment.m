function [aligned_left, aligned_right] = hyperalignment(Q_left, Q_right)
    % Perform hyperalignment on left Q matrix and returns aligned right matrix.

    [aligned_left, transforms] = hyperalign(Q_left{1:3});

    aligned_right{1} = p_transform(transforms{1},Q_right{1});
    aligned_right{2} = p_transform(transforms{2},Q_right{2});
    aligned_right{3} = p_transform(transforms{3},Q_right{3});

end
