rng(mean('hyperalignment'));
colors = get_hyper_colors();

% Correlation analysis in Carey and ADR
datas = {Q, adr_Q};
themes = {'Carey', 'ADR'};

%% Cell-by-cell correlation across subjects
mean_coefs_types = zeros(length(datas), 1);
% sem_coefs_types = zeros(length(datas), 1);
sd_coefs_types = zeros(length(datas), 1);
sub_ids_starts = {[1, 6, 8, 14], [1, 5, 10, 12]};
sub_ids_ends = {[5, 7, 13, 19], [4, 9, 11, 14]};


for d_i = 1:length(datas)
    data = datas{d_i};
    sub_ids_start = sub_ids_starts{d_i};
    sub_ids_end = sub_ids_ends{d_i};
    mean_coefs = zeros(1, length(sub_ids_start));

    for s_i = 1:length(sub_ids_start)
        cell_coefs = [];
        for w_i = sub_ids_start(s_i):sub_ids_end(s_i)
            whiten_left = data{w_i}.left + 0.00001 * rand(size(data{w_i}.left));
            whiten_right = data{w_i}.right + 0.00001 * rand(size(data{w_i}.right));

            for c_i = 1:size(data{w_i}.left, 1)
                [coef] = corrcoef(whiten_left(c_i, :), whiten_right(c_i, :));
                cell_coefs = [cell_coefs, coef(1, 2)];
            end
        end
        mean_coefs(s_i) = mean(cell_coefs, 'omitnan');
    end
    mean_coefs_types(d_i) = mean(mean_coefs);
    % sem_coefs_types(d_i) = std(mean_coefs) / sqrt(length(mean_coefs));
    sd_coefs_types(d_i) = std(mean_coefs);
end

figure; subplot(2, 3, 1);

dx = 0.1;
x = dx * (1:length(datas));
xpad = 0.05;
h = errorbar(x, mean_coefs_types, sd_coefs_types, 'LineStyle', 'none', 'LineWidth', 2);
set(h, 'Color', 'k');
hold on;
plot(x, mean_coefs_types, '.k', 'MarkerSize', 20);
set(gca, 'TickLabelInterpreter', 'latex');
set(gca, 'XTick', x, 'YTick', [-0.05:0.1:0.45], 'XTickLabel', themes, ...
    'XLim', [x(1)-xpad x(end)+xpad], 'YLim', [-0.05 0.45], 'FontSize', 12, ...
    'LineWidth', 1, 'TickDir', 'out');
% title('Cell-by-cell correlation (across subjects)');
box off;
plot([x(1)-xpad x(end)+xpad], [0 0], '--k', 'LineWidth', 1, 'Color', [0.7 0.7 0.7]);

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

%% ID prediction in Carey and ADR
for d_i = 1:length(datas)
    data = datas{d_i};
    [actual_dists_mat, id_dists_mat, sf_dists_mat] = predict_with_shuffles([], data, @predict_with_L_R);

    [z_score, mean_shuffles, proportion, M_ID] = calculate_common_metrics([], actual_dists_mat, ...
    id_dists_mat, sf_dists_mat);

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

    legend([hdl(2), hdl(1)], {'HT','ID'}, 'FontSize', 12)
    legend boxoff
    box off
    ylabel('# of pairs');
    set(gca, 'yticklabel', [], 'FontSize', 12)
end
