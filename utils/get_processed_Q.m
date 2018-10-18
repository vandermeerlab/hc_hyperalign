function [Q] = get_processed_Q(cfg, session_path)
    % Get the data
    cd(session_path);
    LoadMetadata();

    cfg_spikes = {};
    cfg_spikes.load_questionable_cells = 1;
    S = LoadSpikes(cfg_spikes);

    % The end times of left and right trials.
    left_tend = metadata.taskvars.trial_iv_L.tend;
    right_tend = metadata.taskvars.trial_iv_R.tend;

    % Do the left trials first.
    for i = 1:length(left_tend)
        % Regularize the trials
        reg_S.left{i} = restrict(S, left_tend(i) - 5, left_tend(i));

        % Produce the Q matrix (Neuron by Time)
        cfg.tvec_edges = left_tend(i)-5:cfg.dt:left_tend(i);
        Q.left{i} = MakeQfromS(cfg, reg_S.left{i});
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
        reg_S.right{i} = restrict(S, right_tend(i) - 5, right_tend(i));

        cfg.tvec_edges = right_tend(i)-5:cfg.dt:right_tend(i);
        Q.right{i} = MakeQfromS(cfg, reg_S.right{i});
        Q.right{i}.data = zscore(Q.right{i}.data, 0, 2);
    end
end
