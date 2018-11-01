function [plot_obj] = plot_3d_trajectory(a)
    b = cumsum(a, 2); % integrate steps to make trajectory
%     c = conv2(b, ones([11 1]), 'same'); % smooth it
    c = b;
    plot_obj = plot3(c(1, :), c(2, :), c(3, :));
    hold on;
    % Add start and end
    t_start = {c(1, 1), c(2, 1), c(3, 1)};
    plot3(t_start{:}, 'r.', 'MarkerSize', 15);
    text(t_start{:}, '\leftarrow start')
    hold on;
    t_end = {c(1, end), c(2, end), c(3, end)};
    plot3(t_end{:}, 'g.', 'MarkerSize', 15);
    text(t_end{:}, '\leftarrow end')
end