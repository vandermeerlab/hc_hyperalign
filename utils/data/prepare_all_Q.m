function [mean_Q, restrictionLabels] = prepare_all_Q(cfg_in)
    % Get processed data
    cfg_def.paperSessions = 1;
    cfg_def.use_matched_trials = 1;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    data_paths = getTmazeDataPath(cfg);
    restrictionLabels = get_restriction_types(data_paths);

    Q = cell(1, length(data_paths));
    for p_i = 1:length(data_paths)
        Q{p_i} = get_processed_Q(cfg, data_paths{p_i});
    end

    % Average across all left (and right) trials
    for a_i = 1:length(Q)
        Q_left = cellfun(@(x) x.data, Q{a_i}.left, 'UniformOutput', false);
        Q_right = cellfun(@(x) x.data, Q{a_i}.right, 'UniformOutput', false);
        mean_Q{a_i}.left = mean(cat(3, Q_left{:}), 3);
        mean_Q{a_i}.right =  mean(cat(3, Q_right{:}), 3);
    end
end
