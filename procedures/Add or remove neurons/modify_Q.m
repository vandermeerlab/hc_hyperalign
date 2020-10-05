function [new_Q] = modify_Q(old_Q, source, operation, idx, row)
    % Returns a new Q-matrix that either has a new row added or removed
    
    % 1. Source is the idx of the source matrix we're modifying
    % 2. Operation is a string: "add" or "remove"
    % 3. Idx is the index of the neuron to remove, or the index after
    % which to insert the new neuron
    % 4. If we're adding, row (with .right and .left) attributes is the thing
    % we're adding
    

    if strcmp(operation, "add")
        new_Q = old_Q;
        [r,c] = size(old_Q{source}.left);
        new_Q{source}.left = zeros(r+1, c);
        new_Q{source}.left(1:idx,:) = old_Q{source}.left(1:idx,:);
        new_Q{source}.left(idx+1,:) = row.left; % add the desired row (left)
        new_Q{source}.left(idx+2:r+1,:) = old_Q{source}.left(idx+1:r,:);

        new_Q{source}.right = zeros(r+1, c);
        new_Q{source}.right(1:idx,:) = old_Q{source}.right(1:idx,:);
        new_Q{source}.right(idx+1,:) = row.right; % add the desired row (right)
        new_Q{source}.right(idx+2:r+1,:) = old_Q{source}.right(idx+1:r,:);
        
    elseif strcmp(operation, "remove")
        new_Q = old_Q;
        new_Q{source}.left(idx,:)=[];
        new_Q{source}.right(idx,:)=[];
        
    else
        fprintf("Error: operation is invalid")
        new_Q = old_Q;
    end