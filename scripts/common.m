zscore_mat = zeros(length(data));
percent_mat = zeros(length(data));
for i = 1:length(data)
    for j = 1:length(data)
        sf_dists = squeeze(sf_dists_mat(i, j, :))';
        zs = zscore([sf_dists, actual_dists_mat(i, j)]);
        zscore_mat(i, j) = zs(end);
        percent_mat(i, j) = get_percentile(actual_dists_mat(i, j), sf_dists);
    end
end
out_zscore_mat = set_withsubj_nan(zscore_mat);
out_percent_mat = set_withsubj_nan(percent_mat);

sum(sum(out_percent_mat < 0.05)) / sum(sum(~isnan(out_percent_mat)))

% Proportion of actual distance and identity distance smaller than shuffled distances
actual_sf_mat = sum(actual_dists_mat < sf_dists_mat, 3);
id_sf_mat = sum(id_dists_mat < sf_dists_mat, 3);

out_actual_sf_mat = set_withsubj_nan(actual_sf_mat) / 1000;

% Proportion of distance obtained from M smaller than identity mapping
out_actual_dists = set_withsubj_nan(actual_dists_mat);
out_id_dists = set_withsubj_nan(id_dists_mat);
sum(sum(out_actual_dists < out_id_dists)) / sum(sum(~isnan(out_actual_dists)))