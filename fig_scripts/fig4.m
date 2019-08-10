rng(mean('hyperalignment'));
colors = get_hyper_colors();

% Correlation analysis in various simulations: L_R_ind, L_xor_R, L_R_same_μ, sim_HT
datas = {Q_xor, Q_ind, Q_same_mu};
themes = {'x-or', 'ind.', 'ind.(same μ)'};

%% Example inputs
for d_i = 1:length(datas)
    subplot(4, 3, d_i)
    imagesc([datas{d_i}{1}.left, datas{d_i}{1}.right]);
    colorbar;
    set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 12);
    title(themes{d_i});
end

%% ID prediction in various simulations.
for d_i = 1:length(datas)
    data = datas{d_i};
    [actual_dists_mat, id_dists_mat, sf_dists_mat] = predict_with_shuffles([], data, @predict_with_L_R);

    [z_score, mean_shuffles, proportion, M_ID] = calculate_common_metrics([], actual_dists_mat, ...
    id_dists_mat, sf_dists_mat);

    subplot(4, 3, 3 + d_i);
    matrix_obj = {mean_shuffles.out_actual_mean_sf, M_ID.out_M_ID};
    binsize = 10;
    bin_edges = cellfun(@(x) round(min(x(:)), -1):binsize:round(max(x(:)), -1), matrix_obj, 'UniformOutput', false);
    bin_centers = cellfun(@(x) x(1:end-1) + binsize ./ 2, bin_edges, 'UniformOutput', false);
    hist_colors = {colors.HT.hist, colors.ID.hist};
    fit_colors = {colors.HT.fit, colors.ID.fit};
    sub_types = {'HT', 'ID'};

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
        smoothing_factor = 10;
        pd = fitdist(matrix_obj{f_i}(:), 'Normal');
        fitted_range = bin_centers{max_i}(1):(binsize/smoothing_factor):bin_centers{max_i}(end);
        pd_values = pdf(pd, fitted_range);
        % normalize pdf
        pd_values = pd_values / sum(pd_values);
        fitted_values = pd_values * sum(sum(~isnan(matrix_obj{f_i}))) * smoothing_factor;
        fit_plots{f_i} = plot(fitted_range, fitted_values, 'Color', fit_colors{f_i}, 'LineWidth', 1);
        hold on;
        m_metric = median(matrix_obj{f_i}(:), 'omitnan');
        line([m_metric, m_metric], ylim, 'LineWidth', 1, 'Color', fit_colors{f_i}, 'LineStyle', '--')
        hold on;
    end

    line([0, 0], ylim, 'LineWidth', 1, 'Color', 'black')
    legend([fit_plots{1}], {sub_types{d_i}}, 'FontSize', 12)
    legend boxoff
    box off
    ylabel('# of pairs');
    set(gca, 'yticklabel', [], 'FontSize', 12)
end
