%% Welch’s t-test on errors from M prediction and ID prediction
cfg.use_adr_data = 0;
out_actual_dists = set_withsubj_nan(cfg, actual_dists_mat);
out_id_dists = set_withsubj_nan(cfg, id_dists_mat);

[h,p] = ttest2(out_actual_dists(:), out_id_dists(:), 'Vartype','unequal')

%% Chi-square goodness-of-fit test on errors from M prediction and ID prediction
cfg.use_adr_data = 0;
out_actual_dists = set_withsubj_nan(cfg, actual_dists_mat);
out_id_dists = set_withsubj_nan(cfg, id_dists_mat);

out_diff_dists = out_actual_dists - out_id_dists;
[h,p] = chi2gof(out_diff_dists(:))