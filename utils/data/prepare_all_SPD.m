function [SPD] = prepare_all_SPD(cfg_in)
    % Get processed data
    cfg_def.last_n_sec = 2.4;
    cfg_def.use_matched_trials = 1;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    data_paths = getTmazeDataPath(cfg);

    SPD = cell(1, length(data_paths));
    for p_i = 1:length(data_paths)
        cd(data_paths{p_i});
        LoadMetadata();
        LoadExpKeys();
        % Pass conversion factor (convFact) from the ExpKeys to get
        % position in cm/s
        cfg_pos.convFact = ExpKeys.convFact;
        pos = LoadPos(cfg_pos);
        spd = getLinSpd([],pos);
        % The end times of left and right trials.
        if cfg.use_matched_trials
            [matched_left, matched_right] = GetMatchedTrials({}, metadata, ExpKeys);
            L_tstart = matched_left.tstart; R_tstart = matched_right.tstart;
            L_tend = matched_left.tend; R_tend = matched_right.tend;
        else
            L_tstart = metadata.taskvars.trial_iv_L.tstart; R_tstart = metadata.taskvars.trial_iv_R.tstart;
            L_tend = metadata.taskvars.trial_iv_L.tend; R_tend = metadata.taskvars.trial_iv_R.tend;
        end

        left_spd = restrict(spd, L_tend - cfg.last_n_sec, L_tend);
        SPD{p_i}.left = left_spd.data;
        right_spd = restrict(spd, R_tend - cfg.last_n_sec, R_tend);
        SPD{p_i}.right = right_spd.data;
    end

end
