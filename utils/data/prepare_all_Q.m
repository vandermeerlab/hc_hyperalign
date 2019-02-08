function [Q_norm, Q, restrictionLabels] = prepare_all_Q(cfg_in)
    % Get processed data
    cfg_def = [];
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    if cfg.use_adr_data
        data_paths = getAdrDataPath(cfg);
    else
        data_paths = getTmazeDataPath(cfg);
        restrictionLabels = get_restriction_types(data_paths);
    end

    Q_norm = cell(1, length(data_paths));
    Q = cell(1, length(data_paths));
    for p_i = 1:length(data_paths)
        [Q_norm{p_i}, Q{p_i}] = get_processed_Q(cfg, data_paths{p_i});
    end
end
