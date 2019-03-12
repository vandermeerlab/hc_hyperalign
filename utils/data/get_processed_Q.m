function [Q] = get_processed_Q(cfg_in, session_path)

    cfg_def.last_n_sec = 2.4;
    cfg_def.use_matched_trials = 1;
    cfg_def.use_adr_data = 0;
    cfg_def.removeInterneurons = 0;
    cfg_def.minSpikes = 25;

    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    % Get the data
    cd(session_path);
    if cfg.use_adr_data
        load_adrlab_data();
    else
        LoadMetadata();
        LoadExpKeys();

        cfg_spikes = {};
        cfg_spikes.load_questionable_cells = 1;
        S = LoadSpikes(cfg_spikes);
        if cfg.removeInterneurons
            cfg_temp = []; cfg_temp.showFRhist = 0;
            csc = LoadCSC([]);
            S = RemoveInterneuronsHC(cfg_temp,S,csc);
        end
    end

    % The end times of left and right trials.
    if cfg.use_matched_trials
        [matched_left, matched_right] = GetMatchedTrials({}, metadata, ExpKeys);
        L_tstart = matched_left.tstart; R_tstart = matched_right.tstart;
        L_tend = matched_left.tend; R_tend = matched_right.tend;
    else
        L_tstart = metadata.taskvars.trial_iv_L.tstart; R_tstart = metadata.taskvars.trial_iv_R.tstart;
        L_tend = metadata.taskvars.trial_iv_L.tend; R_tend = metadata.taskvars.trial_iv_R.tend;
    end

    tstart = [L_tstart; R_tstart];
    tend = [L_tend; R_tend];
    S_matched = restrict(S, tstart, tend);
    
    % Remove cells with insufficient spikes
    spk_count = getSpikeCount([], S_matched);
    cell_keep_idx = spk_count >= cfg.minSpikes;
    S = SelectTS([], S, cell_keep_idx);

    % Common binning and windowing configurations.
    cfg_Q = [];
    cfg_Q.dt = 0.05;
    cfg_Q.smooth = 'gauss';
    cfg_Q.gausswin_size = 1;
    cfg_Q.gausswin_sd = 0.02;

    % Construct Q with a whole session
    Q_whole = MakeQfromS(cfg_Q, S);
    % Restrict Q with only matched trials
    Q_matched = restrict(Q_whole, tstart, tend);
    [Q_L, Q_R] = get_last_n_sec_LR(Q_matched, L_tend, R_tend, cfg.last_n_sec);
    Q = aver_Q_acr_trials(Q_L, Q_R);
    % if strcmp(cfg.normalization, 'all')
    %     Q_norm = Q_matched;
    %     Q_norm.data = zscore(Q_matched.data, 0, 2);
    %     [Q_norm_L, Q_norm_R] = get_last_n_sec_LR(Q_norm, L_tend, R_tend, cfg.last_n_sec);
    %     Q_norm = aver_Q_acr_trials(Q_norm_L, Q_norm_R);
    % end
end

% Keep only last few seconds for left and right trials
function [Q_L, Q_R] = get_last_n_sec_LR(Q, L_tend, R_tend, last_n_sec)
    for l_i = 1:length(L_tend)
        Q_L{l_i} = restrict(Q, L_tend(l_i) - last_n_sec, L_tend(l_i));
        Q_L{l_i} = Q_L{l_i}.data;
    end
    for r_i = 1:length(R_tend)
        Q_R{r_i} = restrict(Q, R_tend(r_i) - last_n_sec, R_tend(r_i));
        Q_R{r_i} = Q_R{r_i}.data;
    end
end

function [mean_Q] = aver_Q_acr_trials(Q_L, Q_R)
    mean_Q.left = mean(cat(3, Q_L{:}), 3);
    mean_Q.right =  mean(cat(3, Q_R{:}), 3);
end
