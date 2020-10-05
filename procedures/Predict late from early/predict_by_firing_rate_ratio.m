function [dist] = predict_by_firing_rate_ratio(cfg_in, source, target)
    % process config
    cfg_def.dist_dim = 'all';
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def, cfg_in, mfun);

    % input validity
    if ~(source.valid && target.valid)
       fprintf("Warning: inputs do not reflect valid sessions\n");
       dist = 0;
       return;
    end
    
    % make and assess prediction
    activity_ratio = mean(mean(source.late)) / mean(mean(source.early));
    prediction = activity_ratio * target.early;
    ground_truth = target.late;
    dist = calculate_dist(cfg.dist_dim, prediction, ground_truth);

 