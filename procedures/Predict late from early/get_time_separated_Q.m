function Q = get_time_separated_Q(cfg_in, session_path, direction)
    % 'session path' should be the name of a session directory
    %   e.g. 'R042-2013-08-16'
    % 'direction' should be either 'L' or 'R'

    % If the specified session has the required number of trials in the
    % specified direction (at least 2 * cfg.num_trials_to_combine), return
    % a structure with attributes
    %   .early = average Q across the early trials
    %   .late = average Q across the late trials
    %   .valid = true
    % Otherwise, return a structure with the attribute
    %   .valid = false
    
    cfg_def.last_n_sec = 4.3; % the duration of the shortest trial (session 16, trial 4)
    cfg_def.num_trials_to_combine = 5; % how many trials to combine into each of Q.early, Q.late
    % cfg_def.use_matched_trials = 1;
    % cfg_def.use_adr_data = 0;
    cfg_def.removeInterneurons = 1;
    % cfg_def.int_thres = 10;
    % cfg_def.normalization = 'none';
    cfg_def.dt = 0.05;
    % cfg_def.minSpikes = 25;

    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);
    
    % initialize Q to 'not valid'
    Q = {};
    Q.valid = false;
    
    % Get the metadata
    cd(session_path);
    LoadMetadata();
    LoadExpKeys();
    
    % Check: does the session have enough trials in the desired direction?
    % (if not, give an error)
    if strcmp(direction, 'L')
        nTrials = length(metadata.taskvars.trial_iv_L.tstart);
        minTrials = 2 * cfg.num_trials_to_combine; % how many trials we need
        if nTrials < minTrials
            warning('Error in session %s: needed %d L trials, but only found %d\n', session_path, minTrials, nTrials);
            return;
        end
    elseif strcmp(direction, 'R')
        nTrials = length(metadata.taskvars.trial_iv_R.tstart);
        minTrials = 2 * cfg.num_trials_to_combine; % how many trials we need
        if nTrials < minTrials
            warning('Error in session %s: needed %d R trials, but only found %d\n', session_path, minTrials, nTrials);
            return;
        end
    end

    % Get the data   
    cfg_spikes = {};
    cfg_spikes.load_questionable_cells = 1;
    S = LoadSpikes(cfg_spikes);

    % Set the binning and windowing configurations
    cfg_Q = [];
    cfg_Q.dt = cfg.dt;
    cfg_Q.smooth = 'gauss';
    cfg_Q.gausswin_size = 1;
    cfg_Q.gausswin_sd = 0.05;

    % Construct Q with a whole session
    Q_whole = MakeQfromS(cfg_Q, S);
    
    % Get the end times of the early and late trials
    if strcmp(direction, 'L')
        early_tend = metadata.taskvars.trial_iv_L.tend(1:cfg.num_trials_to_combine);
        late_tend = metadata.taskvars.trial_iv_L.tend(nTrials - cfg.num_trials_to_combine + 1:nTrials);
    elseif strcmp(direction, 'R')
        early_tend = metadata.taskvars.trial_iv_R.tend(1:cfg.num_trials_to_combine);
        late_tend = metadata.taskvars.trial_iv_R.tend(nTrials - cfg.num_trials_to_combine + 1:nTrials);
    end
    
    % Use end times to restrict Q to only the specified trials
    % (either early and late R trials or early and late L trials)
    [early_Q, late_Q] = splice_Q_early_late(Q_whole, early_tend, late_tend, cfg.last_n_sec, cfg_Q.dt);

    % average all early trials together, as well as all late trials
    % (Q is now an object with two matrices: Q.early and Q.late)
    Q = aver_Q_acr_trials(early_Q, late_Q);
    
    % Make unit into firing rate (previously was spike count)
    Q.early = Q.early / cfg.dt;
    Q.late = Q.late / cfg.dt;
    
    % Indicate that Q was valid
    Q.valid = true;
end

% Splices Q by trials, and stores the pieces in two structures: 
% early_Q and late_Q
% Inputs:
%   Q: the un-spliced Q matrix
%   early_tend: a list of ending times for the early trials
%   late_tend: a list of ending times for the late trials
%   last_n_seconds: the amount of time allowed for each trial (counting
%       back from end)
%   dt: the width of each bin in Q
function [early_Q, late_Q] = splice_Q_early_late(Q, early_tend, late_tend, last_n_sec, dt)
    for i = 1:length(early_tend)
        early_Q{i} = restrict(Q, early_tend(i) - (last_n_sec + dt), early_tend(i) + dt);
        early_Q{i} = early_Q{i}.data;
    end
    for j = 1:length(late_tend)
        late_Q{j} = restrict(Q, late_tend(j) - (last_n_sec + dt), late_tend(j) + dt);
        late_Q{j} = late_Q{j}.data;
    end
end

% average all early_Q trials into mean_Q.early, and, likewise, all late_Q trials
% into mean_Q.late
function [mean_Q] = aver_Q_acr_trials(early_Q, late_Q)
    mean_Q.early = mean(cat(3, early_Q{:}), 3);
    mean_Q.late =  mean(cat(3, late_Q{:}), 3);
end
