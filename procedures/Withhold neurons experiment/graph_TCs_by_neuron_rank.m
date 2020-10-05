function graph_TCs_by_neuron_rank(cfg_in, Q, TC, actual_dists_mat, source, target)
    TC_LENGTH = 41; % the number of entries in each tuning curve

    FIGURE_PATH = strcat('C:\Users\willb\Documents\van der Meer Lab\Projects\', cfg_in.figure_folder_path);
    
    % determine how many neurons were recorded for the source animal
    [height, ~] = size(Q{source}.left);
    num_neurons = height;

    % get the contribution of each neuron
    dist_changes = zeros(num_neurons, 1);
    for neuron = 1:num_neurons
        new_dist = predict_without_neuron([], Q, source, neuron, target);
        dist_changes(neuron) = new_dist - actual_dists_mat(source, target);
    end
    
    % plot a histogram of the distance changes
    norm_dist_changes = dist_changes / actual_dists_mat(source, target);
    figure;
    histogram(100 * norm_dist_changes);
    title('Changes to prediction accuracy when each neuron is withheld');
    xlabel('Percentage change in distance between prediction and truth');
    ylabel('Number of neurons');

    % save the histogram
    figure_name = sprintf('source_%d_target_%d', source, target);
    hist_figure_name = strcat(figure_name, '_hist');
    hist_file_name = strcat(FIGURE_PATH, hist_figure_name, '.png');
    print(gcf,'-dpng','-r300', hist_file_name);
    fprintf(strcat('successfully made figure \"', hist_figure_name, '\"\n'));
    
    % rank the neurons by that contribution
    dist_changes_copy = dist_changes(:,:);
    neuron_ranking = zeros(num_neurons, 1);
    for rank = 1:num_neurons
        max_idx = 1;
        for idx = 1:num_neurons
            if dist_changes_copy(idx) > dist_changes_copy(max_idx)
                max_idx = idx;
            end
        end
        neuron_ranking(rank)= max_idx;
        dist_changes_copy(max_idx) = -Inf;
    end
    
    % order the tuning curves by the neuron ranking
    left_matrix = zeros(num_neurons, TC_LENGTH);
    right_matrix = zeros(num_neurons, TC_LENGTH);
    
    for row = 1:num_neurons
        left_matrix(row,:) = TC{source}.left(neuron_ranking(row),:);
        right_matrix(row,:) = TC{source}.right(neuron_ranking(row),:);
    end
    
    % plot the figure
    imagesc([left_matrix, right_matrix]);
    ylabel('Neuron (in order of change to prediction distance)');
    set(gca, 'XTick', []);
    set(gca, 'Layer', 'bottom');

    % (colorbar)
    cb=colorbar;
    cb.Label.String = 'Firing rate (Hz)';

    % (Add the 'L' and 'R' labels)
    text(0.5 * TC_LENGTH, num_neurons + 3, 'L', 'FontSize', 14);
    text(1.5 * TC_LENGTH, num_neurons + 3, 'R', 'FontSize', 14);

    % (plot the horizontal white dashed line)
    last_non_neg = 1;  % the index of the last neuron whose contribution is non-negative
    while dist_changes(neuron_ranking(last_non_neg)) >= 0
        last_non_neg = last_non_neg + 1;
    end
    
    hold on;
    zero_y = zeros(2 * TC_LENGTH,1) + last_non_neg - 0.5;
    plot(1:(2 * TC_LENGTH), zero_y, 'w--');

    % (outline the left and right)
    rectangle('Position', [TC_LENGTH + 0.5, 0.5, TC_LENGTH, num_neurons], 'EdgeColor', [0 0 0.6], 'Linewidth', 2);
    rectangle('Position', [0.5, 0.5, TC_LENGTH, num_neurons], 'EdgeColor', 'r', 'Linewidth', 2);
    hold off;
    
    % save the figure
    set(gcf, 'InvertHardcopy', 'off')
   
    file_name = strcat(FIGURE_PATH, figure_name, '.png');
    print(gcf,'-dpng','-r300', file_name);
    message = strcat('successfully made figure \"', figure_name, '\"\n');
    fprintf(message);
    
    % normalize the tuning curves (making sure to turn Nans into 0
    normalized_left_matrix = transpose(normalize(transpose(left_matrix)));
    normalized_right_matrix = transpose(normalize(transpose(right_matrix)));
    normalized_left_matrix(isnan(normalized_left_matrix)) = 0;
    normalized_right_matrix(isnan(normalized_right_matrix)) = 0;
    
    % plot the normalized figure
    imagesc([normalized_left_matrix, normalized_right_matrix]);
    ylabel('Neuron (in order of change to prediction distance)');
    set(gca, 'XTick', []);
    set(gca, 'Layer', 'bottom');

    % (colorbar)
    cb=colorbar;
    cb.Label.String = 'Firing rate (Hz)';

    % (Add the 'L' and 'R' labels)
    text(0.5 * TC_LENGTH, num_neurons + 3, 'L', 'FontSize', 14);
    text(1.5 * TC_LENGTH, num_neurons + 3, 'R', 'FontSize', 14);

    % (plot the horizontal white dashed line)
    hold on;
    zero_y = zeros(2 * TC_LENGTH,1) + last_non_neg - 0.5;
    plot(1:(2 * TC_LENGTH), zero_y, 'w--');

    % (outline the left and right)
    rectangle('Position', [TC_LENGTH + 0.5, 0.5, TC_LENGTH, num_neurons], 'EdgeColor', [0 0 0.6], 'Linewidth', 2);
    rectangle('Position', [0.5, 0.5, TC_LENGTH, num_neurons], 'EdgeColor', 'r', 'Linewidth', 2);
    hold off;

    % save the normalized figure
    normalized_figure_name = sprintf('source_%d_target_%d_normalized', source, target);
    print(gcf,'-dpng','-r300', strcat(FIGURE_PATH, normalized_figure_name, '.png'));
    fprintf(strcat('successfully made figure \"', normalized_figure_name, '\"\n'));
    
    % plot the average best and worst TCs
    plot_average_top_and_bottom_TCs(left_matrix, right_matrix, cfg_in, figure_name, FIGURE_PATH, TC_LENGTH, num_neurons);



    