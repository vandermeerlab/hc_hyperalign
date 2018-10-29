function [plot_obj] = plot_3d_trajectory(a)
    b = cumsum(a, 2); % integrate steps to make trajectory
    c = conv2(b, ones([11 1]), 'same'); % smooth it
    plot_obj = plot3(c(8, :), c(9, :), c(10, :));
end