%%
figure;
Q = [2, 2, 2, 1, 0;
     0, 1, 2, 2, 2;
     0, 0, 1, 2, 2];
plot3(Q(1, 1), Q(2, 1), Q(3, 1), 'r.', 'MarkerSize', 50); % t1
hold on;
plot3(Q(1, 2), Q(2, 2), Q(3, 2), 'r.', 'MarkerSize', 50); % t2
hold on;
plot3(Q(1, 3), Q(2, 3), Q(3, 3), 'r.', 'MarkerSize', 50); % t3
hold on;
plot3(Q(1, 4), Q(2, 4), Q(3, 4), 'r.', 'MarkerSize', 50); % t4
hold on;
plot3(Q(1, 5), Q(2, 5), Q(3, 5), 'r.', 'MarkerSize', 50); % t5
hold on;

set(gca, 'LineWidth', 1, 'FontSize', 24);
xlabel('Neuron 1'); ylabel('Neuron 2'); zlabel('Neuron 3');