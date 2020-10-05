% Created 8/24/20
function [dist, new_source] = predict_late_from_early_with_shuffle(cfg_in, source, target)
    % shuffles the rows in source.early and source.late,
    % then calls predict_late_from_early
    
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
    
    % shuffle
    [n, t] = size(source.early);
    early_order = randperm(n);
    late_order = randperm(n);
    
    new_source = {};
    new_source.valid = true;
    new_source.early = zeros(n, t);
    new_source.late = zeros(n, t);
    
    for i = 1:n
        new_source.early(i,:) = source.early(early_order(i),:);
        new_source.late(i,:) = source.late(late_order(i),:);
    end
    
    dist = predict_late_from_early(cfg, new_source, target);
    