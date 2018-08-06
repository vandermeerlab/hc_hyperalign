function plot3D(Qmat)
    colors = linspecer(2);
    for i_left = 1:numel(Qmat.left)
        Q_left = Qmat.left{i_left}.Q;
        plot3(Q_left(1, :), Q_left(2, :), Q_left(3, :), 'color', colors(1,:));
        hold on;
    end
    for i_right = 1:numel(Qmat.right)
        Q_right = Qmat.right{i_right}.Q;
        plot3(Q_right(1, :), Q_right(2, :), Q_right(3, :), 'color', colors(2,:));
        hold on;
    end
    grid on;
end