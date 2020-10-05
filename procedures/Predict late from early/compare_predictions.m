function [changes] = compare_predictions(cfg_in, new_func, old_func, time_Q_left, time_Q_right)
    cfg_def.dist_dim = 'all';
    cfg_def.verbose = false;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def, cfg_in, mfun);

    left_left_changes = []; % prediction_dist - null_prediction_dist
    left_right_changes = [];
    right_left_changes = [];
    right_right_changes = [];

    for i = 1:19
        for j = 1:19
            % source: left; target: left
            source = time_Q_left{i};
            target = time_Q_left{j};

            if i ~= j && source.valid && target.valid
                new_dist = new_func(cfg, source, target);
                old_dist = old_func(cfg, source, target);

                change = new_dist - old_dist;
                if cfg.verbose
                    fprintf("Source: left %d, target: left %d, change: %f.\n", i, j, change);
                end
                left_left_changes = [left_left_changes, change];
            end

            % source: left; target: right
            source = time_Q_left{i};
            target = time_Q_right{j};

            if i ~= j && source.valid && target.valid
                new_dist = new_func(cfg, source, target);
                old_dist = old_func(cfg, source, target);

                change = new_dist - old_dist;
                if cfg.verbose
                    fprintf("Source: left %d, target: right %d, change: %f.\n", i, j, change);
                end
                left_right_changes = [left_right_changes, change];
            end

            % source: right; target: left
            source = time_Q_right{i};
            target = time_Q_left{j};

            if i ~= j && source.valid && target.valid
                new_dist = new_func(cfg, source, target);
                old_dist = old_func(cfg, source, target);

                change = new_dist - old_dist;
                if cfg.verbose
                    fprintf("Source: right %d, target: left %d, change: %f.\n", i, j, change);
                end 
                right_left_changes = [right_left_changes, change];
            end

            % source: right; target: right
            source = time_Q_right{i};
            target = time_Q_right{j};

            if i ~= j && source.valid && target.valid
                new_dist = new_func(cfg, source, target);
                old_dist = old_func(cfg, source, target);

                change = new_dist - old_dist;
                if cfg.verbose
                    fprintf("Source: right %d, target: right %d, change: %f.\n", i, j, change);
                end
                right_right_changes = [right_right_changes, change];
            end
        end
    end
    
    changes = {};
    changes.left_left = left_left_changes;
    changes.left_right = left_right_changes;
    changes.right_left = right_left_changes;
    changes.right_right = right_right_changes;
    changes.all = [left_left_changes, left_right_changes, right_left_changes, right_right_changes];
    
    improvements = 0;
    for i = 1:length(changes.all)
        if changes.all(i) < 0
            improvements = improvements + 1;
        end
    end
    
    changes.improvements = improvements;