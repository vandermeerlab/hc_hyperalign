function [all_neuron_rankings] = get_neuron_rankings(all_dist_changes)
    for source = 1:19
        for target = 1:19
            if source ~= target
                dist_changes = all_dist_changes{source, target};
                
                num_neurons = length(dist_changes);
                neuron_ranking = zeros(num_neurons, 1);
                
                for rank = 1:num_neurons
                    max_idx = 1;
                    for idx = 1:num_neurons
                        if dist_changes(idx) > dist_changes(max_idx)
                            max_idx = idx;
                        end
                    end
                    neuron_ranking(max_idx)= rank;
                    dist_changes(max_idx) = -Inf;
                end
                all_neuron_rankings{source, target} = neuron_ranking;
            end
        end
    end
    
    fprintf("Finished ranking neurons for all source-target pairs.\n", source, target);