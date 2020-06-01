%% Get Carey Q inputs.
cfg_data = [];
cfg_data.use_adr_data = 0;
% Fig 2 and supp. fig 2 use removeInterneurons = 0, otherwise 1.
cfg_data.removeInterneurons = 1;
cfg_data.normalization = 'none';
[Q, int_idx] = prepare_all_Q(cfg_data);

%% Get Carey normalized Q inputs. (supp_fig_3)
cfg_data = [];
cfg_data.use_adr_data = 0;
cfg_data.removeInterneurons = 1;

% options: 'none', 'average_norm_Z', 'average_norm_l2'.
cfg_data.normalization = 'average_norm_Z';
[Q_norm_Z] = prepare_all_Q(cfg_data);

cfg_data.normalization = 'average_norm_l2';
[Q_norm_l2] = prepare_all_Q(cfg_data);

%% Get ADR Q inputs.
cfg_data = [];
cfg_data.use_adr_data = 1;
% Fig 2 use removeInterneurons = 0, otherwise 1.
cfg_data.removeInterneurons = 1;
[adr_Q] = prepare_all_Q(cfg_data);

%% Get Carey TC inputs.
cfg_data = [];
cfg_data.only_use_cp = 1;
% Supp. fig 2 use removeInterneurons = 0, otherwise 1.
cfg_data.removeInterneurons = 1;
cfg_data.normalization = 'none';
[TC] = prepare_all_TC(cfg_data);

%% Get Carey normalized TC inputs. (supp_fig_3)
cfg_data.removeInterneurons = 1;

cfg_data.normalization = 'ind_Z';
[TC_norm_Z] = prepare_all_TC(cfg_data);

cfg_data.normalization = 'ind_l2';
[TC_norm_l2] = prepare_all_TC(cfg_data);

%% Get Carey running speed inputs.
SPD = prepare_all_SPD([]);
