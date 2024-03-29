function [TC, restrictionLabels] = prepare_all_TC(cfg_in)
    % Get processed data
    cfg_def.only_use_cp = 1;
    cfg_def.normalization = 'none';
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    data_paths = getTmazeDataPath(cfg);
    restrictionLabels = get_restriction_types(data_paths);

    TC = cell(1, length(data_paths));
    for p_i = 1:length(data_paths)
        TC{p_i} = get_tuning_curve(cfg, data_paths{p_i});
    end

    if cfg.only_use_cp
        % Use data that is after the choice point
        % Find the time bin that the max of choice points among all trials correspond to
        left_cp_bins = cellfun(@(x) (x.left.cp_bin), TC);
        right_cp_bins = cellfun(@(x) (x.right.cp_bin), TC);
        max_cp_bin = max([left_cp_bins, right_cp_bins]);
        keep_idx = max_cp_bin:100;
    else
        keep_idx = 1:100;
    end

    for i = 1:length(TC)
        TC{i} = structfun(@(x) x.tc(:, keep_idx), TC{i}, 'UniformOutput', false);
        
        if ~strcmp(cfg.normalization, 'none')
            TC{i} = normalize_Q(cfg.normalization, TC{i});
        end
        if cfg.only_use_cp
            TC{i} = structfun(@(x) x(:, 2:end), TC{i}, 'UniformOutput', false);
        end
    end
end
