function [z_score, mean_shuffles, proportion, M_ID] = calculate_common_metrics(cfg_in, actual_dists_mat, ...
    id_dists_mat, sf_dists_mat)
    % Calculate common metrics
    cfg_def.use_adr_data = 0;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    if ~isfield(cfg, 'sub_ids_starts') && ~isfield(cfg, 'sub_ids_ends')
        sub_ids = get_sub_ids_start_end();
        if cfg.use_adr_data
            cfg.sub_ids_starts = sub_ids.start.adr;
            cfg.sub_ids_ends = sub_ids.end.adr;
        else
            cfg.sub_ids_starts = sub_ids.start.carey;
            cfg.sub_ids_ends = sub_ids.end.carey;
        end
    end

    %% Matrix of zscores of actual distance among shuffle distances.
    zscore_mat = zeros(size(actual_dists_mat));
    percent_mat = zeros(size(actual_dists_mat));
    for i = 1:size(actual_dists_mat, 1)
        for j = 1:size(actual_dists_mat, 2)
            sf_dists = squeeze(sf_dists_mat(i, j, :))';
            zs = zscore([sf_dists, actual_dists_mat(i, j)]);
            zscore_mat(i, j) = zs(end);
            percent_mat(i, j) = get_percentile(actual_dists_mat(i, j), sf_dists);
        end
    end
    out_zscore_mat = set_withsubj_nan(cfg, zscore_mat);
    z_score.out_zscore_mat = out_zscore_mat;
    z_score.out_zscore_prop = sum(sum(out_zscore_mat < 0)) / sum(sum(~isnan(out_zscore_mat)));

    % Signed rank test vs. 0 (two tailed)
    z_score.sr_p = signrank(out_zscore_mat(:));

    %% Matrix of differences between actual distance (identity distance) and mean of shuffled distance.
    actual_mean_sf = actual_dists_mat - mean(sf_dists_mat, 3);
    out_actual_mean_sf = set_withsubj_nan(cfg, actual_mean_sf);

    % Proportion of distance obtained from M smaller than mean of shuffled distance.
    mean_shuffles.out_actual_mean_sf_prop = sum(sum(out_actual_mean_sf < 0)) / sum(sum(~isnan(out_actual_mean_sf)));
    % Signed rank test vs. 0 (two tailed)
    mean_shuffles.sr_p = signrank(out_actual_mean_sf(:));

    % Normalize into 0 to 1
    % norm_mean_sf = out_actual_mean_sf - min(out_actual_mean_sf(:));
    % norm_mean_sf = out_actual_mean_sf;
    % mean_shuffles.out_actual_mean_sf = norm_mean_sf / (max(norm_mean_sf(:)) - min(norm_mean_sf(:)));
    mean_shuffles.out_actual_mean_sf = out_actual_mean_sf;

    %% Proportion of actual distance and identity distance smaller than shuffled distances
    actual_sf_mat = sum(actual_dists_mat > sf_dists_mat, 3);
    proportion.out_actual_sf_mat = set_withsubj_nan(cfg, actual_sf_mat) / size(sf_dists_mat, 3);
    % One-sample Kolmogorov-Smirnov test against uniform
    uniform_pd = makedist('Uniform');
    [~, proportion.ks_p] = kstest(proportion.out_actual_sf_mat(:), 'CDF', uniform_pd);

    % Proportion of distance obtained from M smaller than identity mapping
    % M_ID.out_M_ID = set_withsubj_nan(cfg, (actual_dists_mat - id_dists_mat));
    out_actual_dists = set_withsubj_nan(cfg, actual_dists_mat);
    out_id_dists = set_withsubj_nan(cfg, id_dists_mat);
    M_ID.out_actual_dists = out_actual_dists;
    M_ID.out_id_dists = out_id_dists;
    M_ID.out_id_prop = sum(sum(out_actual_dists < out_id_dists)) / sum(sum(~isnan(out_actual_dists)));

    % Binomial stats
    M_ID.bino_p_id = calculate_bino_p(sum(sum(out_actual_dists < out_id_dists)), sum(sum(~isnan(out_actual_dists))), 0.5);
end
