function plot3D(X, Y)
    colors = linspecer(2);
    plot3(X(:, 1), X(:, 2), X(:, 3), '.', 'color', colors(1,:), 'markersize', 10);
    hold on;
    plot3(Y(:, 1), Y(:, 2), Y(:, 3), '.', 'color', colors(2,:), 'markersize', 10);
    hold on;
    grid on;
end