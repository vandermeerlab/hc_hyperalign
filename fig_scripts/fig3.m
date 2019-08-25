rng(mean('hyperalignment'));
colors = get_hyper_colors();
sub_ids = get_sub_ids_start_end();

% Correlation analysis in Carey and ADR
datas = {Q, adr_Q};
themes = {'Carey', 'ADR'};

%% Cell-by-cell correlation across subjects
cfg_cell_plot = [];
cfg_cell_plot.ax = subplot(2, 3, 1);
cfg_cell_plot.sub_ids_starts = {sub_ids.start.carey};
cfg_cell_plot.sub_ids_ends = {sub_ids.end.carey};
cfg_cell_plot.ylim = [-0.05, 0.45];

plot_cell_by_cell(cfg_cell_plot, datas, themes)

set(gcf, 'Position', [316 185 898 721]);

%% Population Vector analysis
for d_i = 1:length(datas)
    data = datas{d_i};
    data = cellfun(@(x) [x.left, x.right], data, 'UniformOutput', false);
    coefs = cell(1, length(data));

    w_len = size(data{1}, 2);
    for i = 1:length(data)
        w_coefs = zeros(w_len, w_len);
        for j = 1:w_len
            for k = 1:w_len
                [coef] = corrcoef(data{i}(:, j), data{i}(:, k));
                w_coefs(j, k) = coef(1, 2);
            end
        end
        coefs{i} = w_coefs;
    end

    mean_coefs = mean(cat(3, coefs{:}), 3);
    subplot(2, 3, 1 + d_i)
    imagesc(mean_coefs);
    colorbar;
    this_scale = [0 1]; caxis(this_scale);
    xlabel('L -> R'); ylabel('L -> R');
end

%% Hyperalignment procedure
% Carey: 1, ADR: 2;
datas = {Q, adr_Q};
for d_i = 1:length(datas)
    data = datas{d_i};
    [actual_dists_mat{d_i}, id_dists_mat{d_i}, sf_dists_mat{d_i}] = predict_with_shuffles([], data, @predict_with_L_R);
end

%% ID prediction in Carey and ADR
for d_i = 1:length(datas)
    [~, ~, ~, M_ID] = calculate_common_metrics([], actual_dists_mat{d_i}, ...
        id_dists_mat{d_i}, sf_dists_mat{d_i});

    subplot(2, 3, 4 + d_i);
    matrix_obj = {M_ID.out_actual_dists, M_ID.out_id_dists};
    binsize = 50;
    bin_edges = cellfun(@(x) round(min(x(:)), -1):binsize:round(max(x(:)), -1), matrix_obj, 'UniformOutput', false);
    % Find the max-spanning range so that both ranges can be covered.
    com_bin_edges = min(cell2mat(bin_edges)):binsize:(max(cell2mat(bin_edges)) + binsize);
    bin_centers = com_bin_edges(1:end-1) + binsize ./ 2;
    hist_colors = {colors.HT.hist, colors.ID.hist};
    fit_colors = {colors.HT.fit, colors.ID.fit};

    for h_i = 1:length(matrix_obj)
        % histogram
        hists{h_i} = histcounts(matrix_obj{h_i}(:), com_bin_edges);
        hold on;
    end
    hdl = bar(bin_centers, [hists{1}; hists{2}]', 'grouped');
    set(hdl(1), 'FaceColor', hist_colors{1}, 'EdgeColor', 'none');
    set(hdl(2), 'FaceColor', hist_colors{2}, 'EdgeColor', 'none');

    % Find the bins with largest length so the fitting could span the whole range.
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
    end

    legend([hdl(1), hdl(2)], {'HT','ID'}, 'FontSize', 12)
    legend boxoff
    box off
    ylabel('# of pairs');
    set(gca, 'yticklabel', [], 'FontSize', 12)
end
