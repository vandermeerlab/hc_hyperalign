function mat_output = set_withsubj_nan(cfg_in, mat_input)
    cfg_def.use_adr_data = 0;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);
    
    if cfg.use_adr_data
        mat_output = mat_input;
        mat_output(1:4, 1:4) = NaN;
        mat_output(5:9, 5:9) = NaN;
        mat_output(10:11, 10:11) = NaN;
        mat_output(12:15, 12:15) = NaN;
        mat_output(16:end, 16:end) = NaN;
    else
        mat_output = mat_input;
        mat_output(1:5, 1:5) = NaN;
        mat_output(6:7, 6:7) = NaN;
        mat_output(8:13, 8:13) = NaN;
        mat_output(14:end, 14:end) = NaN;
    end
end
