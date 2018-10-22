zscore_mat = zeros(length(Q));
percent_mat = zeros(length(Q));
for mat_i = 1:numel(zscore_mat)
    zs = zscore([rand_dists_mat{mat_i}, dist_mat(mat_i)]);
    zscore_mat(mat_i) = zs(end);
    percent_mat(mat_i) = get_percentile(dist_mat(mat_i), rand_dists_mat{mat_i});
end

unpred_zscore_mat = zeros(length(Q));
unpred_percent_mat = zeros(length(Q));
for mat_i = 1:numel(unpred_zscore_mat)
    zs = zscore([rand_dists_mat{mat_i}, dist_LR_mat(mat_i)]);
    unpred_zscore_mat(mat_i) = zs(end);
    unpred_percent_mat(mat_i) = get_percentile(dist_LR_mat(mat_i), rand_dists_mat{mat_i});
end

sum(sum(out_percent_mat < 0.05)) / sum(sum(~isnan(out_percent_mat)));
