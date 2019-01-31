function [TC, restrictionLabels] = prepare_all_TC(cfg_in)
    % Get processed data
    cfg_def.paperSessions = 1;
    cfg_def.use_matched_trials = 1;
    cfg_def.only_use_cp = 1;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    data_paths = getTmazeDataPath(cfg);
    restrictionLabels = get_restriction_types(data_paths);

    TC = cell(1, length(data_paths));
    for p_i = 1:length(data_paths)
        TC{p_i} = get_tuning_curve(cfg, data_paths{p_i});
    end

    if cfg.only_use_cp
        % Find the time bin that the max of choice points among all trials correspond to
        left_cp_bins = cellfun(@(x) (x.left.cp_bin), TC);
        right_cp_bins = cellfun(@(x) (x.right.cp_bin), TC);
        max_cp_bin = max([left_cp_bins, right_cp_bins]);
        % Use data that is after the choice point
        for i = 1:length(TC)
            TC{i}.left = TC{i}.left.tc(:, max_cp_bin+1:end);
            TC{i}.right = TC{i}.right.tc(:, max_cp_bin+1:end);
        end
    else
        for i = 1:length(TC)
            TC{i}.left = TC{i}.left.tc;
            TC{i}.right = TC{i}.right.tc;
        end
    end
end
