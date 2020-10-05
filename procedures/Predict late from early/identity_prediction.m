function [dist] = identity_prediction(cfg_in, ~, target)
    % process config
    cfg_def.dist_dim = 'all';
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def, cfg_in, mfun);
    
    % get distance
     dist = calculate_dist(cfg.dist_dim, target.left, target.right);