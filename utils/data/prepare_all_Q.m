function [Q, restrictionLabels] = prepare_all_Q(cfg_in)
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
    remove_idx = get_interneuron_idx();

    for p_i = 1:length(data_paths)
        [Q{p_i}] = get_processed_Q(cfg, data_paths{p_i});
        if cfg.removeInterneurons
            Q{p_i}.left(remove_idx{p_i}, :) = []; Q{p_i}.right(remove_idx{p_i}, :) = [];
        end
    end
end
