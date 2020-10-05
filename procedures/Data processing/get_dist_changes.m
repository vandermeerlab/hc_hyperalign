function [all_dist_changes] = get_dist_changes(Q, actual_dists)
    all_dist_changes = cell(19);
    
    for source = 1:19
        for target = 1:19
            if source ~= target
                num_neurons = length(Q{source}.left(:,1));
                
                dist_changes = zeros(num_neurons, 1);
                for neuron = 1:num_neurons
                    new_dist = predict_without_neuron([], Q, source, neuron, target);
                    dist_changes(neuron) = new_dist - actual_dists(source, target);
                end
                
                all_dist_changes{source, target} = dist_changes;
                fprintf("Generated distance changes for source %d, target %d.\n", source, target);
            end
        end
    end