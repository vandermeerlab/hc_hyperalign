function mat_output = set_withsubj_nan(cfg_in, mat_input)
    cfg_def.use_adr_data = 0;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    if isempty(cfg.sub_ids_starts) && isempty(cfg.sub_ids_ends)
        sub_ids = get_sub_ids_start_end();
        if cfg.use_adr_data
            cfg.sub_ids_starts = sub_ids.start.adr;
            cfg.sub_ids_ends = sub_ids.end.adr;
        else
            cfg.sub_ids_starts = sub_ids.start.carey;
            cfg.sub_ids_ends = sub_ids.end.carey;
        end
    end

    if iscell(mat_input)
        empty_val = {NaN};
    else
        empty_val = NaN;
    end

    for s_i = 1:length(cfg.sub_ids_starts)
        s_start = cfg.sub_ids_starts(s_i);
        s_end = cfg.sub_ids_ends(s_i);

        mat_output = mat_input;
        mat_output(s_start:s_end, s_start:s_end) = empty_val;
    end
end
