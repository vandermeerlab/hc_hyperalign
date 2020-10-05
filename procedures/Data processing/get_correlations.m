function [all_correlations] = get_correlations(Q)
    NBINS = length(Q{1,2}.left(1,:)); % how many time bins there are
    
    all_correlations = cell(1, 19);

    for session = 1:19
        num_neurons = length(Q{session}.left(:,1));
        correlations = zeros(num_neurons,1);
        for neuron = 1:num_neurons
            whitened_left = Q{session}.left(neuron,:) + 0.00001 * rand(1,NBINS); % add the noise
            whitened_right = Q{session}.right(neuron,:) + 0.00001 * rand(1,NBINS);
            correlation_matrix = corrcoef(whitened_left, whitened_right);
            correlations(neuron) = correlation_matrix(1, 2); % select the left-right correlation (not the auto-correlated parts)
        end

        all_correlations{session} = correlations;
    end
    
    fprintf("Calculated left-right correlations for all sessions.\n");