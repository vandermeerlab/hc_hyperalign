%% Get Carey TC inputs.
cfg_data = [];
cfg_data.only_use_cp = 1;
% Fig. S5 use removeInterneurons = 0, otherwise 1.
cfg_data.removeInterneurons = 0;
cfg_data.normalization = 'none';

[TC] = prepare_all_TC(cfg_data);

subjects = {'R042','R044','R050','R064'};
sub_ids = get_sub_ids_start_end();
sub_ids_starts = sub_ids.start.carey;
sub_ids_ends = sub_ids.end.carey;

%% Derive a transformation f (L -> R) from the template obtained by alignment of N subjects.
for subj_i = 1:length(subjects)
end