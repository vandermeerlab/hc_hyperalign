colors = get_hyper_colors();

%% Hyperalignment procedure
% Carey: 1, ADR: 2;
datas = {Q, adr_Q};
for d_i = 1:length(datas)
    data = datas{d_i};
    [actual_dists_mat{d_i}, id_dists_mat{d_i}, sf_dists_mat{d_i}] = predict_with_shuffles([], data, @predict_with_L_R);
    [actual_dists_mat_pca{d_i}, id_dists_mat_pca{d_i}, sf_dists_mat_pca{d_i}] = predict_with_shuffles([], data, @predict_with_L_R_pca);
end

%% Source-target figures in Carey
[z_score, mean_shuffles, proportion] = calculate_common_metrics([], actual_dists_mat{1}, ...
    id_dists_mat{1}, sf_dists_mat{1});

titles = {'Z-scores of HT', 'HT - mean of shuffled', 'Proportion > shuffled'};
matrix_obj = {z_score.out_zscore_mat, mean_shuffles.out_actual_mean_sf, proportion.out_actual_sf_mat};
for m_i = 1:length(matrix_obj)
    subplot(3, 3, m_i);
    imagesc(matrix_obj{m_i},'AlphaData', ~isnan(matrix_obj{m_i}));
    colorbar;
    ylabel('Source Sessions');
    xlabel('Target Sessions');
    title(titles{m_i});
    set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 12);
end

%% Hypertransform and PCA-only in Carey and ADR
% themes = {'Carey', 'ADR'};
x_limits = {[-6, 6], [-500, 500], [0 ,1], [-6, 6], [-500, 500], [0 ,1]};
for d_i = 1:length(datas)
    [z_score, mean_shuffles, proportion] = calculate_common_metrics([], actual_dists_mat{d_i}, ...
        id_dists_mat{d_i}, sf_dists_mat{d_i});
    [z_score_pca, mean_shuffles_pca, proportion_pca] = calculate_common_metrics([], actual_dists_mat_pca{d_i}, ...
        id_dists_mat_pca{d_i}, sf_dists_mat_pca{d_i});

    binsizes = {1, 200, 0.1};
    matrix_objs = {{z_score.out_zscore_mat, z_score_pca.out_zscore_mat}, ...
        {mean_shuffles.out_actual_mean_sf, mean_shuffles_pca.out_actual_mean_sf}, ...
        {proportion.out_actual_sf_mat, proportion_pca.out_actual_sf_mat}};

    for m_i = 1:length(matrix_objs)
        subplot(3, 3, (3 * d_i) + m_i);
        matrix_obj = matrix_objs{m_i};
        binsize = binsizes{m_i};
        if m_i == 2
            bin_edges = cellfun(@(x) round(min(x(:)), -2):binsize:round(max(x(:)), -2), matrix_obj, 'UniformOutput', false);
        else
            bin_edges = cellfun(@(x) floor(min(x(:))):binsize:ceil(max(x(:))), matrix_obj, 'UniformOutput', false);
        end
        % Find the max-spanning range so that both ranges can be covered.
        com_bin_edges = min(cell2mat(bin_edges)):binsize:(max(cell2mat(bin_edges)) + binsize);
        bin_centers = com_bin_edges(1:end-1) + binsize ./ 2;
        hist_colors = {colors.HT.hist, colors.pca.hist};
        fit_colors = {colors.HT.fit, colors.pca.fit};

        for h_i = 1:length(matrix_obj)
            % histogram
            hists{h_i} = histcounts(matrix_obj{h_i}(:), com_bin_edges);
%             bar(bin_centers{h_i}, this_h, 'FaceColor', hist_colors{h_i}, 'FaceAlpha', 0.8, 'EdgeColor', 'none');
            hold on;
        end
        hdl = bar(bin_centers, [hists{1}; hists{2}]', 'grouped');
        set(hdl(1), 'FaceColor', hist_colors{1}, 'EdgeColor', 'none');
        set(hdl(2), 'FaceColor', hist_colors{2}, 'EdgeColor', 'none');

        if m_i ~= 3
            for f_i = 1:length(matrix_obj)
                % fit
                smoothing_factor = 10;
                pd = fitdist(matrix_obj{f_i}(:), 'Normal');
                fitted_range = bin_centers(1):(binsize/smoothing_factor):bin_centers(end);
                pd_values = pdf(pd, fitted_range);
                % normalize pdf
                pd_values = pd_values / sum(pd_values);
                fitted_values = pd_values * sum(sum(~isnan(matrix_obj{f_i}))) * smoothing_factor;
                fit_plots{f_i} = plot(fitted_range, fitted_values, 'Color', fit_colors{f_i}, 'LineWidth', 1);
                hold on;
                if m_i ~= 3
                    m_metric = mean(matrix_obj{f_i}(:), 'omitnan');
                    plot(m_metric, max(fitted_values), '.', 'Color', fit_colors{f_i}, 'MarkerSize', 15)
                    hold on;
                end
            end
        end

        if m_i ~= 3
            line([0, 0], ylim, 'LineWidth', 1, 'Color', 'black')
        end
        xlim(x_limits{(d_i-1)*3+m_i});
        legend([hdl(1), hdl(2)], {'Hypertransform','PCA - only'}, 'FontSize', 12)
        legend boxoff
        box off
        ylabel('# of pairs');
        set(gca, 'yticklabel', [], 'FontSize', 12);
    end
end
