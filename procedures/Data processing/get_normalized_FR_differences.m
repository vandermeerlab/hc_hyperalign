function [all_norm_dFRs] = get_normalized_FR_differences(my_average_activities)
    FRs = {};
    FRs.left = convert_to_array(my_average_activities.left);
    FRs.right = convert_to_array(my_average_activities.right);
    
    n = length(FRs.left);
    all_norm_dFRs = zeros(n,1);
    
    for i = 1:n
        L = FRs.left(i); R = FRs.right(i);
        all_norm_dFRs(i) = (L - R) / (L + R);
    end