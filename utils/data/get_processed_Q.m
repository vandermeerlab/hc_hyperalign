function [Q, int_idx] = get_processed_Q(cfg_in, session_path)
    cfg_def.last_n_sec = 2.4;
    cfg_def.use_matched_trials = 1;
    cfg_def.use_adr_data = 0;
    cfg_def.removeInterneurons = 0;
    cfg_def.int_thres = 10;
    cfg_def.normalization = 'none';
    cfg_def.half_split = 0;
    cfg_def.left_one_out = 0;
    % time bin
    cfg_def.dt = 0.05;
    % cfg_def.minSpikes = 25;

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
    end
    int_idx = [];
    if cfg.removeInterneurons
        channels = FindFiles('*.Ncs');
        cfg_lfp = []; cfg_lfp.fc = {channels{1}};
        lfp = LoadCSC(cfg_lfp);

        cfg_int = []; cfg_int.showFRhist = 0;
        cfg_int.max_fr = cfg.int_thres;
        [S, int_idx] = RemoveInterneuronsHC(cfg_int,S, lfp);
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

    % tstart = [L_tstart; R_tstart];
    tend = [L_tend; R_tend];
    tstart = tend - cfg.last_n_sec;

    % Common binning and windowing configurations.
    cfg_Q = [];
    cfg_Q.dt = cfg.dt;
    cfg_Q.smooth = 'gauss';
    cfg_Q.gausswin_size = 1;
    cfg_Q.gausswin_sd = 0.05;

    % Construct Q with a whole session
    Q_whole = MakeQfromS(cfg_Q, S);
    % Restrict Q with only matched trials
    [Q_L, Q_R] = get_last_n_sec_LR(Q_whole, L_tend, R_tend, cfg.last_n_sec, cfg_Q.dt);
    
    pre_idx = 1:length(Q_R);
    if cfg.left_one_out
        one_idx = randsample(length(Q_R), 1);
        pre_idx(one_idx) = [];
        Q_R_one = Q_R(one_idx);
    end
    if cfg.half_split
        half_idx = datasample(pre_idx, ceil(length(pre_idx) / 2), 'Replace', false);
        Q_R_split = Q_R(half_idx);
    end
    
    Q_R_pre = Q_R(pre_idx);

    Q = aver_Q_acr_trials(Q_L, Q_R_pre);
    
    if cfg.left_one_out
        Q.right_one = Q_R_one{1};
    end
    if cfg.half_split
        Q.right_half = mean(cat(3, Q_R_split{:}), 3);
    end
    
    % Make unit into firing rate
    Q = structfun(@(x) x / cfg.dt, Q, 'UniformOutput', false);
    
    if ~strcmp(cfg.normalization, 'none')
        Q = normalize_Q(cfg.normalization, Q);
    end
        
%     % Not used for now.
%     elseif strcmp(cfg.normalization, 'norm_average')
%         Q_L_matched = restrict(Q_whole, L_tstart, L_tend);
%         % Q_L_matched.data = zscore(Q_L_matched.data, 0, 2);
%         Q_L_matched.data = row_wise_norm(Q_L_matched.data);
% 
%         Q_R_matched = restrict(Q_whole, R_tstart, R_tend);
%         % Q_R_matched.data = zscore(Q_R_matched.data, 0, 2);
%         Q_R_matched.data = row_wise_norm(Q_R_matched.data);
% 
%         dt = 0.05;
%         for l_i = 1:length(L_tend)
%             Q_L{l_i} = restrict(Q_L_matched, L_tend(l_i) - (cfg.last_n_sec + cfg.dt), L_tend(l_i) + cfg.dt);
%             Q_L{l_i} = Q_L{l_i}.data;
%         end
%         for r_i = 1:length(R_tend)
%             Q_R{r_i} = restrict(Q_R_matched, R_tend(r_i) - (cfg.last_n_sec + cfg.dt), R_tend(r_i) + cfg.dt);
%             Q_R{r_i} = Q_R{r_i}.data;
%         end
% 
%         % [Q_L, Q_R] = get_last_n_sec_LR(Q_matched, L_tend, R_tend, cfg.last_n_sec, cfg.dt);
%         w_len = size(Q_L{1}, 2);
% 
%         % Q_L_norm = zscore(horzcat(Q_L{:}), 0, 2);
%         % Q_R_norm = zscore(horzcat(Q_R{:}), 0, 2);
%         % Q_L_norm = row_wise_norm(horzcat(Q_L{:}));
%         % Q_R_norm = row_wise_norm(horzcat(Q_R{:}));
%         % for i = 1:length(Q_L)
%         %     Q_L{i} = Q_L_norm(:, (i-1)*w_len+1:i*w_len);
%         %     Q_R{i} = Q_R_norm(:, (i-1)*w_len+1:i*w_len);
%         % end
%         Q = aver_Q_acr_trials(Q_L, Q_R);

% Normalize across whole session, which we don't consider for now.
% Q_matched = restrict(Q_whole, tstart, tend);
% Q_matched.data = zscore(Q_matched.data, 0, 2);
end

% Keep only last few seconds for left and right trials
function [Q_L, Q_R] = get_last_n_sec_LR(Q, L_tend, R_tend, last_n_sec, dt)
    for l_i = 1:length(L_tend)
        Q_L{l_i} = restrict(Q, L_tend(l_i) - (last_n_sec + dt), L_tend(l_i) + dt);
        Q_L{l_i} = Q_L{l_i}.data;
    end
    for r_i = 1:length(R_tend)
        Q_R{r_i} = restrict(Q, R_tend(r_i) - (last_n_sec + dt), R_tend(r_i) + dt);
        Q_R{r_i} = Q_R{r_i}.data;
    end
end

function [mean_Q] = aver_Q_acr_trials(Q_L, Q_R)
    mean_Q.left = mean(cat(3, Q_L{:}), 3);
    mean_Q.right = mean(cat(3, Q_R{:}), 3);
end
