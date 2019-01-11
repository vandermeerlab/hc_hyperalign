zscore_mat = zeros(length(Q));
percent_mat = zeros(length(Q));
for mat_i = 1:numel(zscore_mat)
    zs = zscore([sf_dists_mat{mat_i}, actual_dists_mat(mat_i)]);
    zscore_mat(mat_i) = zs(end);
    percent_mat(mat_i) = get_percentile(actual_dists_mat(mat_i), sf_dists_mat{mat_i});
end
out_zscore_mat = set_withsubj_nan(zscore_mat);
out_percent_mat = set_withsubj_nan(percent_mat);

unpred_zscore_mat = zeros(length(Q));
unpred_percent_mat = zeros(length(Q));
for mat_i = 1:numel(unpred_zscore_mat)
    zs = zscore([rand_dists_mat{mat_i}, dist_LR_mat(mat_i)]);
    unpred_zscore_mat(mat_i) = zs(end);
    unpred_percent_mat(mat_i) = get_percentile(dist_LR_mat(mat_i), rand_dists_mat{mat_i});
end

sum(sum(out_percent_mat < 0.05)) / sum(sum(~isnan(out_percent_mat)));

for p_i = 1:length(TC)
    [~, ~, shuffle_M{p_i}] = procrustes(s_aligned_target{p_i}', s_aligned_source{p_i}');
    pre{p_i} = p_transform(shuffle_M{p_i}, s_aligned_source{8});
end