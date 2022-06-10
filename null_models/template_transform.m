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

data = TC;

%%
% Project [L, R] to PCA space.
cfg.NumComponents = 10;
for p_i = 1:length(data)
    pca_input = data{p_i};
    [proj_data{p_i}, eigvecs{p_i}, pca_mean{p_i}] = perform_pca(pca_input, cfg.NumComponents);
end

%% Derive a transformation f (L -> R) from the template obtained by alignment of N - 1 subjects.
% for subj_i = 1:length(subjects)
w_len = 41;

subj_i = 1;
X = proj_data{sub_ids_starts(subj_i)};
Y = proj_data{sub_ids_starts(subj_i + 1)};
Z = proj_data{sub_ids_starts(subj_i + 2)};

tar_i = subj_i + 3;
V = proj_data{sub_ids_starts(tar_i)};

hyper_input = {X, Y, Z};
[aligned_left, aligned_right, transforms, T_left, T_right] = get_aligned_left_right(hyper_input);
template.left = T_left;
template.right = T_right;

% Align the withheld subject to template

hyper_input_val = {template, V};
[aligned_left_val, aligned_right_val, transforms_val] = get_aligned_left_right(hyper_input_val);
aligned_left_tar = aligned_left_val{2};
transforms_tar = transforms_val{2};


% Estimate M from L to R using the template.
[~, ~, M] = procrustes(T_right', T_left', 'scaling', false);
% Apply M to L of the validate session V.
predicted_aligned = p_transform(M, aligned_left_tar);

% Project back to PCA space
project_back_pca = inv_p_transform(transforms_tar, [aligned_left_tar, predicted_aligned]);

% Project back to Q space.
project_back_data = eigvecs{tar_i} * project_back_pca + pca_mean{tar_i};

p_target = project_back_data(:, w_len+1:end);

% end