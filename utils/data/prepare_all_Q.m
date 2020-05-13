function [Q, int_idx, restrictionLabels] = prepare_all_Q(cfg_in)
    % Get processed data
    cfg_def = [];
    cfg_def.use_adr_data = 0;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    if cfg.use_adr_data
        data_paths = getAdrDataPath(cfg);
    else
        data_paths = getTmazeDataPath(cfg);
        restrictionLabels = get_restriction_types(data_paths);
    end

    Q = cell(1, length(data_paths));
    int_idx = cell(1, length(data_paths));

    for p_i = 1:length(data_paths)
        [Q{p_i}, int_idx{p_i}] = get_processed_Q(cfg, data_paths{p_i});
        Q{p_i}.left = Q{p_i}.left(:, 2:end-1);
        Q{p_i}.right = Q{p_i}.right(:, 2:end-1);
    end
end
