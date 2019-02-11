function [TC_norm, TC, restrictionLabels] = prepare_all_TC(cfg_in)
    % Get processed data
    cfg_def.only_use_cp = 1;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    data_paths = getTmazeDataPath(cfg);
    restrictionLabels = get_restriction_types(data_paths);

    TC = cell(1, length(data_paths));
    TC_norm = cell(1, length(data_paths));
    for p_i = 1:length(data_paths)
        TC{p_i} = get_tuning_curve(cfg, data_paths{p_i});
    end

    if cfg.only_use_cp
        % Use data that is after the choice point
        % Find the time bin that the max of choice points among all trials correspond to
        left_cp_bins = cellfun(@(x) (x.left.cp_bin), TC);
        right_cp_bins = cellfun(@(x) (x.right.cp_bin), TC);
        max_cp_bin = max([left_cp_bins, right_cp_bins]);
        keep_idx = max_cp_bin+1:100;
    else
        keep_idx = 1:100;
    end

    for i = 1:length(TC)
        TC{i}.left = TC{i}.left.tc(:, keep_idx);
        TC{i}.right = TC{i}.right.tc(:, keep_idx);
        TC_norm_concat = zscore([TC{i}.left, TC{i}.right], 0, 2);
        w_len = size(TC{i}.left, 2);
        TC_norm{i}.left = TC_norm_concat(:, 1:w_len);
        TC_norm{i}.right = TC_norm_concat(:, w_len+1:end);
    end
end
