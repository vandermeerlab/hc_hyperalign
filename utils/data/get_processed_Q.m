function [Q] = get_processed_Q(cfg_in, session_path)

    cfg_def.use_matched_trials = 0;
    cfg_def.use_adr_data = 0;

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

    % The end times of left and right trials.
    if cfg.use_matched_trials
        [matched_left, matched_right] = GetMatchedTrials({}, metadata, ExpKeys);
        left_tend = matched_left.tend;
        right_tend = matched_right.tend;
    else
        left_tend = metadata.taskvars.trial_iv_L.tend;
        right_tend = metadata.taskvars.trial_iv_R.tend;
    end

    left_start = left_tend - 2.4;
    right_start = right_tend - 2.4;

    % Common binning and windowing configurations.
    cfg_Q = [];
    cfg_Q.dt = 0.05;
    cfg_Q.smooth = 'gauss';
    cfg_Q.gausswin_size = 1;
    cfg_Q.gausswin_sd = 0.02;
    % Do the left trials first.
    for i = 1:length(left_tend)
        % Regularize the trials
        reg_S.left{i} = restrict(S, left_start(i), left_tend(i));

        % Produce the Q matrix (Neuron by Time)
        cfg_Q.tvec_edges = left_start(i):cfg_Q.dt:left_tend(i);
        Q.left{i} = MakeQfromS(cfg_Q, reg_S.left{i});
        % By z-score the smoothed binned spikes, we try to decorrelate the
        % absolute spike rate with the later PCAed space variables.
        % The second variable determine using population standard deviation
        % (1 using n, 0(default) using n-1)
        % The third argument determine the dim, 1 along columns and 2 along
        % rows.
        Q.left{i}.data = zscore(Q.left{i}.data, 0, 2);
    end

    % Do the right trials.
    for i = 1:length(right_tend)
        reg_S.right{i} = restrict(S, right_start(i), right_tend(i));

        cfg_Q.tvec_edges = right_start(i):cfg_Q.dt:right_tend(i);
        Q.right{i} = MakeQfromS(cfg_Q, reg_S.right{i});
        Q.right{i}.data = zscore(Q.right{i}.data, 0, 2);
    end
end
