%% Get Q inputs.
cfg_data = [];
cfg_data.use_adr_data = 0;
cfg_data.removeInterneurons = 0;
% cfg_data.normalization = 'norm_average';
[Q] = prepare_all_Q(cfg_data);

% Remove cells that are significantly correlated between L and R.
% cfg_data.removeCorrelations = 'pos';
% Q = remove_corr_cells(Q, cfg_data.removeCorrelations);

%% Get TC inputs.
cfg_data = [];
cfg_data.only_use_cp = 1;
[TC] = prepare_all_TC(cfg_data);
