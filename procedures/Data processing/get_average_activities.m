function [all_average_activities] = get_average_activities(Q)
    all_average_activities = {};
    all_average_activities.left = cell(1, 19);
    all_average_activities.right = cell(1, 19);

    for session = 1:19
        num_neurons = length(Q{session}.left(:,1));

        all_average_activities.left{session} = zeros(num_neurons,1);
        all_average_activities.right{session} = zeros(num_neurons,1);

        for n = 1:num_neurons
            all_average_activities.left{session}(n) = mean(Q{session}.left(n,:));
            all_average_activities.right{session}(n) = mean(Q{session}.right(n,:)); 
        end   
    end
    
    fprintf("Calculated average firing rate for all neurons in all sessions.\n");