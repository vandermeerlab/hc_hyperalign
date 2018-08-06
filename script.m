% Regularize left and right trials
TSE_L(:, 1) = metadata.taskvars.trial_iv_L.tstart;
TSE_L(:, 2) = metadata.taskvars.trial_iv_L.tend;
TSE_R(:, 1) = metadata.taskvars.trial_iv_R.tstart;
TSE_R(:, 2) = metadata.taskvars.trial_iv_R.tend;
reg_trials = RegularizedTrials(TSE_L, TSE_R);

% Qmat = generateQmatrix(reg_trials, S, 0);
