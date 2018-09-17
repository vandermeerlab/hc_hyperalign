function [aligned_right] = hyperalignment(Q_left, Q_right)
    % Perform hyperalignment on left Q matrix and returns aligned right matrix.

    [aligned_left, transforms] = hyperalign(Q_left{1:3});

    aligned_right{1} = p_transform(transforms{1},Q_right{1});
    aligned_right{2} = p_transform(transforms{2},Q_right{2});
    aligned_right{3} = p_transform(transforms{3},Q_right{3});

end

% % Plot trajectory
% % left
% trajectory_plotter(1, aligned_left{1}, aligned_left{2}, aligned_left{3});
% title('hyperaligned left trials');
%
% % right
% trajectory_plotter(1, aligned_right{1}, aligned_right{2}, aligned_right{3});
% title('hyperaligned right trials');
%
% % non-aligned right trials
% trajectory_plotter(1, lMats{4}, lMats{5}, lMats{6});
% title('non-aligned right trials');
