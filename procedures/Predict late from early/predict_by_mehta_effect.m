% Created by WHB on 8/24/2020.
function [dist, mehta] = predict_by_mehta_effect(cfg_in, source, target)
    % process config
    cfg_def.dist_dim = 'all';
    cfg_def.weights = [0.8, 0.2, 0.15, 0.1, 0.1];
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def, cfg_in, mfun);

    % input validity
    if ~(source.valid && target.valid)
       fprintf("Warning: inputs do not reflect valid sessions\n");
       dist = 0;
       return;
    end
    
    % predict
    [~, t] = size(target.early);

    mehta = zeros(t);
    for i = 1:t % index down the rows of mehta
        for j = 1:length(cfg.weights) % index across weightings
            if (i + j - 1) <= t % ensure we haven't gone off the end of the row
                mehta(i, i + j - 1) = cfg.weights(j); 
            end
        end
    end
    
    prediction = transpose(mehta * transpose(target.early));
    ground_truth = target.late;
    dist = calculate_dist(cfg.dist_dim, prediction, ground_truth);
    