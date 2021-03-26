function [HT_PCA] = calculate_HT_PCA_metrics(cfg_in, actual_dists_mat, actual_dists_mat_pca, actual_dists_mat_sp)
    % Calculate HT vs. PCA metrics
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
    n_subjs = length(cfg.sub_ids_starts);

    out_actual_dists = set_withsubj_nan(cfg, actual_dists_mat);
    out_actual_dists_pca = set_withsubj_nan(cfg, actual_dists_mat_pca);
    out_actual_dists_sp = set_withsubj_nan(cfg, actual_dists_mat_sp);

    HT_PCA.out_actual_dists = out_actual_dists;
    HT_PCA.out_actual_dists_pca = out_actual_dists_pca;
    HT_PCA.out_actual_dists_sp = out_actual_dists_sp;

    diff_HT_PCA = out_actual_dists - out_actual_dists_pca;
    pair_count = sum(sum(~isnan(diff_HT_PCA)));

    HT_PCA.bino_ps = calculate_bino_p(sum(sum(diff_HT_PCA <= 0)), pair_count, 0.5);
    HT_PCA.signrank_ps = signrank(out_actual_dists(:),  out_actual_dists_pca(:));
    HT_PCA.prop_HT_PCA = sum(sum(diff_HT_PCA <= 0)) / pair_count;

    HT_PCA.mean_HT = nanmean(out_actual_dists(:));
    HT_PCA.median_HT = nanmedian(out_actual_dists(:));
    HT_PCA.sem_HT = nanstd(out_actual_dists(:)) / sqrt(n_subjs * (n_subjs - 1));

    HT_PCA.mean_PCA = nanmean(out_actual_dists_pca(:));
    HT_PCA.median_PCA = nanmedian(out_actual_dists_pca(:));
    HT_PCA.sem_PCA = nanstd(out_actual_dists_pca(:)) / sqrt(n_subjs * (n_subjs - 1));

    HT_PCA.mean_sp = nanmean(out_actual_dists_sp(:));
    HT_PCA.median_sp = nanmedian(out_actual_dists_sp(:));
    HT_PCA.sem_sp = nanstd(out_actual_dists_sp(:)) / sqrt(n_subjs * (n_subjs - 1));
end
