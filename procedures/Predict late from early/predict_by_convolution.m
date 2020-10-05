% Created by WHB on 9/2/2020.

% A more general form of the predict_by_mehta_effect (and reverse) methods.

% f (passed in as cfg.f) is a function with the property that f(1) is how much the predicted
% activity at time t0 is affected by the activity at time t1 = t0 + 1

% In addition to the aforementioned parameter (dt), f may also take
% parameters, specified in the array params (passed in as cfg.params)

% Note to self: makes function calls in the form f(params, x).
function [dist, convolution_matrix] = predict_by_convolution(cfg_in, source, target)
    % process config
    cfg_def.dist_dim = 'all';
    cfg_def.invert = false;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def, cfg_in, mfun);

    % input validity
    if ~(source.valid && target.valid)
       fprintf("Warning: inputs do not reflect valid sessions\n");
       dist = 0;
       return;
    end
    
    [~, t] = size(target.early);

    convolution_matrix = zeros(t);
    for i = 1:t % index from top to bottom of convolution_matrix
        for j = 1:t % index from left to right
            convolution_matrix(i, j) = cfg.f(cfg.params, j - i);
        end
    end
    
    if cfg.invert
        convolution_matrix = inv(convolution_matrix);
    end
    
    prediction = transpose(convolution_matrix * transpose(target.early));
    ground_truth = target.late;
    dist = calculate_dist(cfg.dist_dim, prediction, ground_truth);
    