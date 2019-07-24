colors = get_hyper_colors();

%% Source-target figures in Carey
data = Q;
[actual_dists_mat, id_dists_mat, sf_dists_mat] = predict_with_shuffles([], data, @predict_with_L_R);
[actual_dists_mat_pca, id_dists_mat_pca, sf_dists_mat_pca] = predict_with_shuffles([], data, @predict_with_L_R_pca);

[z_score, mean_shuffles, proportion, M_ID] = calculate_common_metrics([], actual_dists_mat, ...
    id_dists_mat, sf_dists_mat);

titles = {'Z-scores of HT', 'HT - mean of shuffled', 'Proportion > shuffled'};
matrix_obj = {z_score.out_zscore_mat, mean_shuffles.out_actual_mean_sf, proportion.out_actual_sf_mat};
for m_i = 1:length(matrix_obj)
    subplot(3, 3, m_i);
    imagesc(matrix_obj{m_i},'AlphaData', ~isnan(matrix_obj{m_i}));
    colorbar;
    ylabel('Source Sessions');
    xlabel('Target Sessions');
    title(titles{m_i});
    set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 24);
end

%% Hypertransform and PCA-only in Carey and ADR
datas = {Q, adr_Q};
for d_i = 1:length(datas)
    data = datas{d_i};
    [actual_dists_mat, id_dists_mat, sf_dists_mat] = predict_with_shuffles([], data, @predict_with_L_R);
    [actual_dists_mat_pca, id_dists_mat_pca, sf_dists_mat_pca] = predict_with_shuffles([], data, @predict_with_L_R_pca);

    [z_score, mean_shuffles, proportion, M_ID] = calculate_common_metrics([], actual_dists_mat, ...
    id_dists_mat, sf_dists_mat);
    [z_score_pca, mean_shuffles_pca, proportion_pca, M_ID_pca] = calculate_common_metrics([], actual_dists_mat_pca, id_dists_mat_pca, sf_dists_mat_pca);

    binsizes = {1, 100, 0.1};
    matrix_objs = {{z_score_pca.out_zscore_mat, z_score.out_zscore_mat}, ...
        {mean_shuffles_pca.out_actual_mean_sf, mean_shuffles.out_actual_mean_sf}, ...
        {proportion_pca.out_actual_sf_mat, proportion.out_actual_sf_mat}};

    for m_i = 1:length(matrix_objs)
        subplot(3, 3, (3 * d_i) + m_i);
        matrix_obj = matrix_objs{m_i};
        binsize = binsizes{m_i};
        if m_i == 2
            bin_edges = cellfun(@(x) round(min(x(:)), -2):binsize:round(max(x(:)), -2), matrix_obj, 'UniformOutput', false);
        else
            bin_edges = cellfun(@(x) floor(min(x(:))):binsize:ceil(max(x(:))), matrix_obj, 'UniformOutput', false);
        end
        bin_centers = cellfun(@(x) x(1:end-1) + binsize ./ 2, bin_edges, 'UniformOutput', false);
        hist_colors = {colors.carey.pca.hist, colors.carey.HT.hist};
        fit_colors = {colors.carey.pca.fit, colors.carey.HT.fit};

        for h_i = 1:length(matrix_obj)
            % histogram
            this_h = histcounts(matrix_obj{h_i}(:), bin_edges{h_i});
            bar(bin_centers{h_i}, this_h, 'FaceColor', hist_colors{h_i}, 'FaceAlpha', 0.8, 'EdgeColor', 'none');
            hold on;
        end

        % Find the bins with largest length so the fitting could span the whole range.
        [max_v, max_i] = max(cellfun(@length, bin_centers));

        for f_i = 1:length(matrix_obj)
            % fit
            pd = fitdist(matrix_obj{f_i}(:), 'Normal');
            fitted_range = bin_centers{max_i}(1):(binsize):bin_centers{max_i}(end);
            pd_values = pdf(pd, fitted_range);
            pd_values = pd_values / sum(pd_values);
            fitted_values = pd_values * sum(sum(~isnan(matrix_obj{f_i})));
            fit_plots{f_i} = plot(fitted_range, fitted_values, 'Color', fit_colors{f_i}, 'LineWidth', 1);
            hold on;
            if m_i ~= 3
                m_metric = median(matrix_obj{f_i}(:), 'omitnan');
                line([m_metric, m_metric], ylim, 'LineWidth', 1, 'Color', fit_colors{f_i}, 'LineStyle', '--')
                hold on;
            end
        end

        if m_i ~= 3
            line([0, 0], ylim, 'LineWidth', 1, 'Color', 'black')
        end
        legend([fit_plots{2}, fit_plots{1}], {'Hypertransform','PCA - only'}, 'FontSize', 12)
        legend boxoff
        box off
        ylabel('# of pairs');
        set(gca, 'yticklabel', [], 'FontSize', 24)
    end
end
