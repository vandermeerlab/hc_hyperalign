function plot_average_top_and_bottom_TCs(left_matrix, right_matrix, cfg, figure_name, FIGURE_PATH, TC_LENGTH, num_neurons)
    RANK_NUM = cfg.rank_num;

    average_best_TC_left = zeros(1, TC_LENGTH);
    average_best_TC_right = zeros(1, TC_LENGTH);
    average_worst_TC_left = zeros(1, TC_LENGTH);
    average_worst_TC_right = zeros(1, TC_LENGTH);
    for rank = 1:RANK_NUM
        % include the [rank] best neuron in the average best TC
        average_best_TC_left = average_best_TC_left + left_matrix(rank,:);
        average_best_TC_right = average_best_TC_right + right_matrix(rank,:);

        % include the [rank] worst neuron in the average worst TC
        average_worst_TC_left = average_worst_TC_left + left_matrix(num_neurons - rank + 1,:);
        average_worst_TC_right = average_worst_TC_right + right_matrix(num_neurons - rank + 1,:);
    end

    average_best_TC_left = average_best_TC_left / RANK_NUM;
    average_best_TC_right = average_best_TC_right / RANK_NUM;
    average_worst_TC_left = average_worst_TC_left / RANK_NUM;
    average_worst_TC_right = average_worst_TC_right / RANK_NUM;

    % plot the best and worst TCs
    figure;
    subplot(2,2,1);
    plot(1:TC_LENGTH, average_best_TC_left);
    set(gca, 'XTick', []);
    ylabel('Firing rate (Hz)');
    title(sprintf('Average left TC of top %d neurons', RANK_NUM));

    subplot(2,2,2);
    plot(1:TC_LENGTH, average_best_TC_right);
    set(gca, 'XTick', []);
    ylabel('Firing rate (Hz)');
    title(sprintf('Average right TC of top %d neurons', RANK_NUM));

    subplot(2,2,3);
    plot(1:TC_LENGTH, average_worst_TC_left);
    set(gca, 'XTick', []);
    ylabel('Firing rate (Hz)');
    title(sprintf('Average left TC of bottom %d neurons', RANK_NUM));

    subplot(2,2,4);
    plot(1:TC_LENGTH, average_worst_TC_right);
    set(gca, 'XTick', []);
    ylabel('Firing rate (Hz)');
    title(sprintf('Average right TC of bottom %d neurons', RANK_NUM));
    
    % save the figure
    set(gcf, 'InvertHardcopy', 'off')
    best_and_worst_figure_name = strcat(figure_name, '_best_and_worst');
    file_name = strcat(FIGURE_PATH, best_and_worst_figure_name, '.png');
    print(gcf,'-dpng','-r300', file_name);
    message = strcat('successfully made figure \"', best_and_worst_figure_name, '\"\n');
    fprintf(message);