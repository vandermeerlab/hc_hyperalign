function [plot_obj] = plot_3d_trajectory(a)
    b = a;
%     b = cumsum(a, 2); % integrate steps to make trajectory
    for i = 1:size(b, 1)
        % smooth each dimension independently
        c(i, :) = conv(b(i, :), ones(21, 1), 'same');
    end
%     c = b;
    plot_obj = plot3(c(1, :), c(2, :), c(3, :));
    set(plot_obj, 'LineWidth', 5);
    set(gca, 'LineWidth', 1, 'XTick', [], 'YTick',[], 'ZTick', [], 'FontSize', 24);
%     xlabel('PC1'); ylabel('PC2'); zlabel('PC3');
    hold on;

    % Mark start and end
    t_start = {c(1, 1), c(2, 1), c(3, 1)};
    plot3(t_start{:}, 'g.', 'MarkerSize', 120);
    hold on;

%     t_end = {c(1, end), c(2, end), c(3, end)};
%     plot3(t_end{:}, 'r.', 'MarkerSize', 120);
end
