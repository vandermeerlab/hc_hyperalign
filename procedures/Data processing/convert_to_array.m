function [array] = convert_to_array(input)
    % A little bit of a funky method, but very useful.
    % Converts data structure into 1d arrays for use in plotting methods.
    
    % Can take inputs that have one of two structures:
    %   1. 19x19 cell, where c{s,t} is an array with one entry per neuron
    %   2. 1x19 cell, were c{s} is an array with one entry per neuron

    array = []; % difficult to pre-allocate since the number of neurons per session is variable

    [r, c] = size(input);
    % case 1: we have a 19x19 cell
    if r == 19 && c == 19
        for source = 1:19
            for target = 1:19
                if source ~= target
                    array = [array; input{source, target}];
                end
            end
        end
        fprintf("Conversion to 1-d array succeeded.\n");
        
    % case 2: we have a 1x19 cell
    elseif c == 19
        for session = 1:19
            for iteraton = 1:18 % repeat the same thing multiple times so that the data match case 1
                array = [array; input{session}];
            end
        end
        fprintf("Conversion to 1-d array succeeded.\n");
        
    % case 3: c is not in a valid form   
    else
        fprintf("Error in convert_to_array: input shout be a 19x19 or 1x19 cell.\n");
    end
   