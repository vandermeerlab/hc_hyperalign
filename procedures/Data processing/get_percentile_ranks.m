function [all_percentile_ranks] = get_percentile_ranks(all_neuron_rankings)
    all_percentile_ranks = cell(19);

    for source = 1:19
        for target = 1:19
            if source ~= target
                ranks = all_neuron_rankings{source, target};
                all_percentile_ranks{source, target} = ranks * 100 / length(ranks);
            end
        end
    end
    
    fprintf("Converted ranks to percentile form.\n");