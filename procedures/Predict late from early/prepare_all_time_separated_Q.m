function [time_Q_left, time_Q_right] = prepare_all_time_separated_Q(cfg_in)
    % Each of "time_Q_left" and "time"Q_right" is a 1x19 cell where
    % each cell time_Q_left/right{i}is a struct with attributes:
    %   .valid (logical) = whether or not there were enough trials in the
    %   desired direction (minimum number is 2*num_trials_to_combine)
    %   .early (matrix, contingent on "valid") = each entry is a firing
    %   rate; columns represent time, rows represent neurons
    %   .late (matrix, contingent on "valid") = comparable to "early"

    % Prepare parameters (right now, just num_trials_to_combine)
    cfg_def.num_trials_to_combine = 5;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def, cfg_in, mfun);
    
    data_paths = getTmazeDataPath({});

    time_Q_left = cell(1, 19); time_Q_right = cell(1, 19);

    % For each data path, prepare the "left" and the "right" time-separated Q
    % (each one has both an early and late component)
    for p = 1:length(data_paths)
        time_Q_left{p} = get_time_separated_Q(cfg, string(data_paths(p)), 'L');
        time_Q_right{p} = get_time_separated_Q(cfg, string(data_paths(p)), 'R');
    end