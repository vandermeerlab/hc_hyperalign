%% Get Carey Q inputs.
cfg_data = [];
cfg_data.use_adr_data = 0;
cfg_data.removeInterneurons = 1;
cfg_data.normalization = 'none';
[Q] = prepare_all_Q(cfg_data);

% Remove cells that are significantly correlated between L and R.
% cfg_data.removeCorrelations = 'pos';
% Q = remove_corr_cells(Q, cfg_data.removeCorrelations);

%% Get Carey normalized Q inputs. (supp_fig_3)
cfg_data = [];
cfg_data.use_adr_data = 0;
cfg_data.removeInterneurons = 1;

% options: 'none', 'average_norm_Z', 'average_norm_l2'.
cfg_data.normalization = 'average_norm_Z';
[Q_norm_Z] = prepare_all_Q(cfg_data);

cfg_data.normalization = 'average_norm_l2';
[Q_norm_l2] = prepare_all_Q(cfg_data);
%% Get ADR Q input
cfg_data = [];
cfg_data.use_adr_data = 1;
cfg_data.removeInterneurons = 1;
[adr_Q] = prepare_all_Q(cfg_data);

%% Get simulated inputs.
cfg_sim = [];
cfg_sim.n_units = cellfun(@(x) size(x.left, 1), Q);

Q_xor = L_xor_R(cfg_sim);
Q_ind = L_R_ind(cfg_sim);
Q_sim_HT = sim_HT(cfg_sim);

cfg_sim.same_params = [1, 1, 1];
Q_same_ps = L_R_ind(cfg_sim);

%% Get Carey TC inputs.
cfg_data = [];
cfg_data.only_use_cp = 1;
cfg_data.removeInterneurons = 1;
cfg_data.normalization = 'none';
[TC] = prepare_all_TC(cfg_data);

%% Get Carey normalized TC inputs. (supp_fig_3)
cfg_data.removeInterneurons = 1;

cfg_data.normalization = 'ind_Z';
[TC_norm_Z] = prepare_all_TC(cfg_data);

cfg_data.normalization = 'ind_l2';
[TC_norm_l2] = prepare_all_TC(cfg_data);