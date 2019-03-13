function mat_output = set_withsubj_nan(cfg_in, mat_input)
    cfg_def.use_adr_data = 0;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    if iscell(mat_input)
        empty_val = {NaN};
    else
        empty_val = NaN;
    end

    if cfg.use_adr_data
        mat_output = mat_input;
        mat_output(1:4, 1:4) = empty_val;
        mat_output(5:9, 5:9) = empty_val;
        mat_output(10:11, 10:11) = empty_val;
        mat_output(12:15, 12:15) = empty_val;
        mat_output(16:end, 16:end) = empty_val;
    else
        mat_output = mat_input;
        mat_output(1:5, 1:5) = empty_val;
        mat_output(6:7, 6:7) = empty_val;
        mat_output(8:13, 8:13) = empty_val;
        mat_output(14:end, 14:end) = empty_val;
    end
end
