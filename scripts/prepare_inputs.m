%%
rng(mean('hyperalignment'));

%% Get Carey Q inputs.
cfg_data = [];
cfg_data.use_adr_data = 0;
% Fig 1b, 2, S3 and S4 use removeInterneurons = 0, otherwise 1.
cfg_data.removeInterneurons = 0;
cfg_data.normalization = 'none';

%%
cfg_data.left_one_out = 0;
cfg_data.half_split = 0;
[Q] = prepare_all_Q(cfg_data);

%% For Fig 2 and S4 inset; half-split error
cfg_data.left_one_out = 0;
cfg_data.half_split = 1;
[Q_split] = prepare_all_Q(cfg_data);

%% For withheld data (one trial) prediction
cfg_data.left_one_out = 1;
cfg_data.half_split = 1;
[Q_one] = prepare_all_Q(cfg_data);

%% Get Carey normalized Q inputs. (Fig. S5)
cfg_data = [];
cfg_data.use_adr_data = 0;
cfg_data.removeInterneurons = 1;

% options: 'none', 'ind_Z', 'ind_l2'.
cfg_data.normalization = 'ind_Z';
[Q_norm_Z] = prepare_all_Q(cfg_data);

cfg_data.normalization = 'ind_l2';
[Q_norm_l2] = prepare_all_Q(cfg_data);

%% Get ADR Q inputs.
cfg_data = [];
cfg_data.use_adr_data = 1;
% Fig 2 use removeInterneurons = 0, otherwise 1.
cfg_data.removeInterneurons = 0;

%%
cfg_data.left_one_out = 0;
cfg_data.half_split = 0;
[adr_Q] = prepare_all_Q(cfg_data);

%% For Fig 2 inset; half-split error
cfg_data.left_one_out = 0;
cfg_data.half_split = 1;
[adr_Q_split] = prepare_all_Q(cfg_data);

%% Get Carey TC inputs.
cfg_data = [];
cfg_data.only_use_cp = 1;
% Fig. S5 use removeInterneurons = 0, otherwise 1.
cfg_data.removeInterneurons = 0;
cfg_data.normalization = 'none';

%%
cfg_data.left_one_out = 0;
cfg_data.half_split = 0;
[TC] = prepare_all_TC(cfg_data);

%% For S4 inset; half-split error
cfg_data.left_one_out = 0;
cfg_data.half_split = 1;
[TC_split] = prepare_all_TC(cfg_data);

%% Get Carey normalized TC inputs. (Fig. S5)
cfg_data = [];
cfg_data.only_use_cp = 1;
cfg_data.removeInterneurons = 1;

cfg_data.normalization = 'ind_Z';
[TC_norm_Z] = prepare_all_TC(cfg_data);

cfg_data.normalization = 'ind_l2';
[TC_norm_l2] = prepare_all_TC(cfg_data);

%% Get Carey running speed inputs.
SPD = prepare_all_SPD([]);
